import os
import requests
import pandas as pd

from datetime import datetime, timedelta, timezone
from zoneinfo import ZoneInfo


# =====================================================
# INSIRA SUA NOVA CHAVE DA STORMGLASS
# =====================================================

API_KEY = "INSIRA SUA CHAVE AQUI"


# =====================================================
# LOCALIDADES
# =====================================================

LOCATIONS = [
    ("Macae", -22.412250, -41.809083),
]


# =====================================================
# CAMINHO DO CSV
# =====================================================

OUTPUT_PATH = (
    r"C:\Users\User\Desktop\YAN ZUBATY\TCC\surfreport.csv"
)


# Fonte meteorológica utilizada neste teste
WEATHER_SOURCE = "noaa"


def to_iso_utc(dt: datetime) -> str:
    """Converte datetime para ISO 8601 em UTC."""

    return (
        dt.astimezone(timezone.utc)
        .replace(microsecond=0)
        .isoformat()
        .replace("+00:00", "Z")
    )


def build_interval():
    """
    Intervalo de consulta:
    - início: 12h UTC do dia anterior;
    - fim: início + 7 dias.
    """

    now_utc = datetime.now(timezone.utc)
    yesterday_utc = (now_utc - timedelta(days=1)).date()

    start_dt_utc = datetime(
        year=yesterday_utc.year,
        month=yesterday_utc.month,
        day=yesterday_utc.day,
        hour=12,
        minute=0,
        second=0,
        tzinfo=timezone.utc,
    )

    end_dt_utc = start_dt_utc + timedelta(days=7)

    return (
        to_iso_utc(start_dt_utc),
        to_iso_utc(end_dt_utc),
    )


# =====================================================
# FUNÇÃO PARA EXTRAIR VALORES DA FONTE NOAA
# =====================================================

def extract_source_value(value, source):
    """
    Extrai somente o valor correspondente à fonte solicitada.

    Aceita respostas nos formatos:
    {"noaa": valor}

    ou:

    [{"source": "noaa", "value": valor}]
    """

    if value is None:
        return None

    if isinstance(value, dict):
        return value.get(source)

    if isinstance(value, list):
        for item in value:
            if (
                isinstance(item, dict)
                and item.get("source") == source
                and "value" in item
            ):
                return item["value"]

        return None

    if isinstance(value, (int, float)):
        return value

    return None


# =====================================================
# WEATHER — SOMENTE NOAA
# =====================================================

def fetch_weather(
    lat: float,
    lng: float,
    start_iso: str,
    end_iso: str,
):
    """Consulta os dados meteorológicos da fonte NOAA."""

    print(
        f"\n=== Consultando WEATHER NOAA "
        f"para {lat}, {lng} ==="
    )

    params = [
        "seaLevel",
        "swellDirection",
        "swellHeight",
        "swellPeriod",
        "secondarySwellDirection",
        "secondarySwellHeight",
        "secondarySwellPeriod",
        "waterTemperature",
        "waveDirection",
        "waveHeight",
        "wavePeriod",
        "windDirection",
        "windSpeed",
        "windWaveDirection",
        "windWaveHeight",
        "windWavePeriod",
    ]

    url = "https://api.stormglass.io/v2/weather/point"

    headers = {
        "Authorization": API_KEY
    }

    query = {
        "lat": lat,
        "lng": lng,
        "params": ",".join(params),
        "start": start_iso,
        "end": end_iso,
        "source": WEATHER_SOURCE,
    }

    response = requests.get(
        url,
        headers=headers,
        params=query,
        timeout=30,
    )

    print("Status WEATHER NOAA:", response.status_code)

    if response.status_code != 200:
        print("\nERRO EM /v2/weather/point:")
        print(response.text)
        response.raise_for_status()

    return response.json()


def build_weather_df(
    data: dict,
    localidade: str,
    lat: float,
    lng: float,
) -> pd.DataFrame:
    """Transforma a resposta NOAA em DataFrame."""

    hours = data.get("hours", [])

    print(
        f"Horas WEATHER NOAA para {localidade}: "
        f"{len(hours)}"
    )

    rows = []

    for hour in hours:
        row = {
            "time_utc": hour.get("time"),
            "Localidade": localidade,
            "Coordenadas": f"{lat:.6f}, {lng:.6f}",
        }

        for key, value in hour.items():
            if key == "time":
                continue

            row[key] = extract_source_value(
                value,
                WEATHER_SOURCE,
            )

        rows.append(row)

    df = pd.DataFrame(rows)

    if df.empty:
        return df

    def to_local(time_value):
        if not isinstance(time_value, str):
            return None

        try:
            dt_utc = datetime.fromisoformat(
                time_value.replace("Z", "+00:00")
            )

            return dt_utc.astimezone(
                ZoneInfo("America/Sao_Paulo")
            ).isoformat()

        except Exception:
            return None

    df["time_local"] = df["time_utc"].apply(to_local)

    cols_keep = [
        "Localidade",
        "Coordenadas",
        "time_local",
        "time_utc",
        "seaLevel",
        "swellDirection",
        "swellHeight",
        "swellPeriod",
        "secondarySwellDirection",
        "secondarySwellHeight",
        "secondarySwellPeriod",
        "waterTemperature",
        "waveDirection",
        "waveHeight",
        "wavePeriod",
        "windDirection",
        "windSpeed",
        "windWaveDirection",
        "windWaveHeight",
        "windWavePeriod",
    ]

    # Cria como vazias as colunas que a NOAA não retornar.
    # Isso mantém o CSV compatível com o Power BI.
    for column in cols_keep:
        if column not in df.columns:
            df[column] = None

    return df[cols_keep]


# =====================================================
# MARÉ — ENDPOINT ESPECÍFICO
# =====================================================

def fetch_tide(
    lat: float,
    lng: float,
    start_iso: str,
    end_iso: str,
):
    """
    Consulta o nível do mar.

    A maré permanece na fonte sg porque não faz parte
    da troca do modelo meteorológico para NOAA.
    """

    print(
        f"\n=== Consultando TIDE para {lat}, {lng} ==="
    )

    url = (
        "https://api.stormglass.io/"
        "v2/tide/sea-level/point"
    )

    headers = {
        "Authorization": API_KEY
    }

    query = {
        "lat": lat,
        "lng": lng,
        "start": start_iso,
        "end": end_iso,
        "datum": "MSL",
        "source": "sg",
    }

    response = requests.get(
        url,
        headers=headers,
        params=query,
        timeout=30,
    )

    print("Status TIDE:", response.status_code)

    if response.status_code != 200:
        print("\nERRO EM /v2/tide/sea-level/point:")
        print(response.text)
        response.raise_for_status()

    return response.json()


def build_tide_df(
    data: dict,
    localidade: str,
    lat: float,
    lng: float,
) -> pd.DataFrame:
    """Transforma a resposta de maré em DataFrame."""

    data_points = data.get("data", [])

    print(
        f"Horas TIDE para {localidade}: "
        f"{len(data_points)}"
    )

    rows = []

    for point in data_points:
        row = {
            "time_utc": point.get("time"),
            "Localidade": localidade,
            "Coordenadas": f"{lat:.6f}, {lng:.6f}",
        }

        if "sg" in point:
            row["tide_seaLevel"] = point.get("sg")
        else:
            row["tide_seaLevel"] = None

            for key, value in point.items():
                if key not in ["time", "meta"]:
                    row["tide_seaLevel"] = value
                    break

        rows.append(row)

    return pd.DataFrame(rows)


# =====================================================
# EXECUÇÃO
# =====================================================

def main():
    start_iso, end_iso = build_interval()

    print(
        f"Intervalo UTC: {start_iso} -> {end_iso}"
    )

    print(
        f"Fonte meteorológica selecionada: "
        f"{WEATHER_SOURCE.upper()}"
    )

    all_dfs = []

    for name, lat, lng in LOCATIONS:
        try:
            weather_json = fetch_weather(
                lat,
                lng,
                start_iso,
                end_iso,
            )

            df_weather = build_weather_df(
                weather_json,
                name,
                lat,
                lng,
            )

            tide_json = fetch_tide(
                lat,
                lng,
                start_iso,
                end_iso,
            )

            df_tide = build_tide_df(
                tide_json,
                name,
                lat,
                lng,
            )

            if df_weather.empty:
                print(
                    f"Nenhum dado NOAA retornado "
                    f"para {name}."
                )
                continue

            df_merged = pd.merge(
                df_weather,
                df_tide[
                    [
                        "Localidade",
                        "time_utc",
                        "tide_seaLevel",
                    ]
                ],
                on=["Localidade", "time_utc"],
                how="left",
            )

            all_dfs.append(df_merged)

        except Exception as error:
            print(
                f"\nErro ao processar {name}: {error}"
            )

    if not all_dfs:
        print(
            "\nNenhum dado foi retornado "
            "para nenhuma localidade."
        )
        return

    df_all = pd.concat(
        all_dfs,
        ignore_index=True,
    )

    # Pasta onde serão salvos o CSV principal e os backups
    output_dir = os.path.dirname(OUTPUT_PATH)

    os.makedirs(
        output_dir,
        exist_ok=True,
    )

    # Arquivo principal usado pelo Power BI
    df_all.to_csv(
        OUTPUT_PATH,
        index=False,
        encoding="utf-8",
    )

    # Data do download no formato DD.MM
    data_download = datetime.now(
        ZoneInfo("America/Sao_Paulo")
    ).strftime("%d.%m")

    # Backup diário salvo na mesma pasta
    backup_filename = f"surfreport ({data_download}).csv"
    backup_path = os.path.join(
        output_dir,
        backup_filename,
    )

    df_all.to_csv(
        backup_path,
        index=False,
        encoding="utf-8",
    )

    print("\nCSV principal atualizado com sucesso em:")
    print(OUTPUT_PATH)

    print("\nBackup diário salvo com sucesso em:")
    print(backup_path)

    print("\nDepois, atualize o Power BI.")


if __name__ == "__main__":
    main()
