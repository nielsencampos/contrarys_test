import requests as rq
import io       as io
import pandas   as pd
from ast            import literal_eval
from sqlalchemy     import create_engine
from sqlalchemy.orm import sessionmaker

vEngine     = create_engine("postgresql+psycopg2://postgres:contrarys_test@172.19.0.2:5432/postgres")
vConnection = vEngine.connect()

vCompaniesURL                          = "https://contrary-engineering-interview.s3.amazonaws.com/data/companies.csv"
vCompaniesCSV                          = rq.get(vCompaniesURL).content
vCompaniesPD                           = pd.read_csv(io.StringIO(vCompaniesCSV.decode("utf-8")))
vCompaniesPD.columns                   = vCompaniesPD.columns.str.lower()
vCompaniesPD["company_linkedin_names"] = vCompaniesPD["company_linkedin_names"].apply(lambda x: literal_eval(str(x).replace("nan", "None")))
vCompaniesPD["investors"]              = vCompaniesPD["investors"].apply(lambda x: literal_eval(str(x).replace("nan", "None")))
vConnection.execute("TRUNCATE TABLE stg_companies")
vCompaniesPD.to_sql(            "stg_companies",
                    con       = vEngine,
                    if_exists = "append",
                    index     = False)
vConnection.execute("TRUNCATE TABLE companies")
vCompaniesSQL = "INSERT INTO companies SELECT " + ", ".join(vCompaniesPD.columns) + " FROM (SELECT " + ", ".join(vCompaniesPD.columns) + ", (ROW_NUMBER() OVER(PARTITION BY name ORDER BY 1 ASC)) AS rank_filter FROM stg_companies) final_companies WHERE rank_filter = 1 AND name IS NOT NULL"
print(vCompaniesSQL)
vConnection.execute(vCompaniesSQL)
vConnection.execute("TRUNCATE TABLE stg_companies")


vPeopleURL                          = "https://contrary-engineering-interview.s3.amazonaws.com/data/people.csv"
vPeopleCSV                          = rq.get(vPeopleURL).content
vPeoplePD                           = pd.read_csv(io.StringIO(vPeopleCSV.decode("utf-8")))
vPeoplePD.columns                   = vPeoplePD.columns.str.lower()
vConnection.execute("TRUNCATE TABLE stg_people")
vPeoplePD.to_sql(            "stg_people",
                    con       = vEngine,
                    if_exists = "append",
                    index     = False)
vConnection.execute("TRUNCATE TABLE people")
vPeopleSQL = "INSERT INTO people SELECT " + ", ".join(vPeoplePD.columns) + " FROM (SELECT " + ", ".join(vPeoplePD.columns) + ", (ROW_NUMBER() OVER(PARTITION BY person_id, company_name ORDER BY 1 ASC)) AS rank_filter FROM stg_people) final_people WHERE rank_filter = 1 AND person_id IS NOT NULL AND company_name IS NOT NULL"
print(vPeopleSQL)
vConnection.execute(vPeopleSQL)
vConnection.execute("TRUNCATE TABLE stg_people")