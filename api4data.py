import                        psycopg2
import                        pandas
from fastapi           import FastAPI, status
from fastapi.responses import JSONResponse
from pydantic          import BaseModel
import                        uvicorn

app = FastAPI(title        = "Contrary's Data API",
              description  = "Contrary's Data API for Test.",
              version      = "1.0.0",
              openapi_tags = [{"name"        : "avg-funding-by-person",
                               "description" : "/avg-funding-by-person/[person_id] -> This route will accept a person_id, and return the dynamic answer to question 1 for the person_id requested. (if there is no funding value then return 0)."},
                              {"name"        : "companies-by-person",
                               "description" : "/companies-by-person/[person_id] -> This route will accept a person_id and return a list of all of the companies that person has worked at."},
                              {"name"        : "investors-by-company",
                               "description" : "/investors-by-company/[company_linkedin_name] -> This route will accept a company by any of its linkedin names, and return a list of the investors."}])

def executeQuery(sql):
    vConnection = psycopg2.connect(host     = "172.19.0.2",
                                   port     = "5432",
                                   database = "postgres",
                                   user     = "postgres",
                                   password = "contrarys_test")
    vDF         = pandas.read_sql(      sql,
                                  con = vConnection)
    return vDF

class avg_funding_by_person_return(BaseModel):
    average_total_funding : float
class companies_by_person_return_company(BaseModel):
    company               : str
class companies_by_person_return(BaseModel):
    companies             : companies_by_person_return_company
class investors_by_company_return_investor(BaseModel):
    investor              : str
class investors_by_company_return(BaseModel):
    investors             : investors_by_company_return_investor

@app.get(                 "/avg-funding-by-person/{person_id}",
         tags           = ["avg-funding-by-person"],
         response_model = avg_funding_by_person_return)
async def avg_funding_by_person(person_id):
    vStatus                           = status.HTTP_100_CONTINUE
    vContent                          = {}
    vContent["average_total_funding"] = None
    vResult                           = executeQuery(sql = "SELECT (AVG(COALESCE(c.known_total_funding, 0))) AS average_total_funding FROM people p LEFT JOIN companies c ON p.company_name = c.name WHERE p.person_id = '" + person_id + "'")
    if vResult is not None:
        vStatus = status.HTTP_200_OK
        for vIndex, vRow in vResult.iterrows():
            vContent["average_total_funding"] = float(vRow["average_total_funding"])
        if vContent["average_total_funding"] is None:
            vStatus             = status.HTTP_400_BAD_REQUEST
            vContent["warning"] = "No person found by the id provided."
    else:
        vStatus           = status.HTTP_500_INTERNAL_SERVER_ERROR
        vContent["error"] = []
        vContent["error"].append("Internal error, try again in a couple of minutes.")
    return JSONResponse(status_code = vStatus,
                        content     = vContent)

@app.get(                 "/companies-by-person/{person_id}",
         tags           = ["companies-by-person"],
         response_model = companies_by_person_return)
async def companies_by_person(person_id):
    vStatus               = status.HTTP_100_CONTINUE
    vContent              = {}
    vContent["companies"] = []
    vResult               = executeQuery(sql = "SELECT p.company_name FROM people p WHERE p.person_id = '" + person_id + "' ORDER BY p.company_name ASC")
    if vResult is not None:
        vStatus = status.HTTP_200_OK
        for vIndex, vRow in vResult.iterrows():
            vContent["companies"].append(vRow["company_name"])
        if len(vContent["companies"]) == 0:
            vStatus             = status.HTTP_400_BAD_REQUEST
            vContent["warning"] = "No person found by the id provided."
    else:
        vStatus           = status.HTTP_500_INTERNAL_SERVER_ERROR
        vContent["error"] = []
        vContent["error"].append("Internal error, try again in a couple of minutes.")
    return JSONResponse(status_code = vStatus,
                        content     = vContent)

@app.get(                 "/investors-by-company/{company_linkedin_name}",
         tags           = ["investors-by-company"],
         response_model = investors_by_company_return)
async def investors_by_company(company_linkedin_name):
    vStatus               = status.HTTP_100_CONTINUE
    vContent              = {}
    vContent["investors"] = []
    vResult  = executeQuery(sql = "WITH query_1 AS (SELECT c.name, (UNNEST(c.company_linkedin_names)) AS company_linkedin_name, (UNNEST(c.investors)) AS investor FROM companies c), query_2 AS (SELECT q.name, q.company_linkedin_name, q.investor FROM query_1 q WHERE q.company_linkedin_name IS NOT NULL AND q.investor IS NOT NULL) SELECT q.investor FROM query_2 q WHERE q.company_linkedin_name = '" + company_linkedin_name + "' ORDER BY q.investor ASC")
    if vResult is not None:
        vStatus = status.HTTP_200_OK
        for vIndex, vRow in vResult.iterrows():
            vContent["investors"].append(vRow["investor"])
        if len(vContent["investors"]) == 0:
            vStatus             = status.HTTP_400_BAD_REQUEST
            vContent["warning"] = "No company with investors found by the linkedin_name provided."
    else:
        vStatus           = status.HTTP_500_INTERNAL_SERVER_ERROR
        vContent["error"] = []
        vContent["error"].append("Internal error, try again in a couple of minutes.")
    return JSONResponse(status_code = vStatus,
                        content     = vContent)

#Inicialização do servidor uvicorn
if __name__ == "__main__":
    uvicorn.run(               app,
                host         = "0.0.0.0",
                port         = 4321,
                log_level    = "info")