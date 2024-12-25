import json
import requests


def lambda_handler(event, context):
    route = event.get("path")
    method = event.get("httpMethod")

    if route == "/list-games" and method == "GET":
        return {
            "statusCode": 200,
            "body": json.dumps({"games": ["Chess", "Soccer", "Tennis"]})
        }

    elif route == "/create-game" and method == "POST":
        game = json.loads(event.get("body", "{}"))
        return {
            "statusCode": 201,
            "body": json.dumps({"message": f"Game '{game.get('name', 'Unnamed')}' created."})
        }

    elif route == "/update-game" and method == "PUT":
        game = json.loads(event.get("body", "{}"))
        return {
            "statusCode": 200,
            "body": json.dumps({"message": f"Game '{game.get('name', 'Unnamed')}' updated."})
        }
    elif route == "/external-call" and method == "GET":
        try:
            response = requests.get("https://api.restful-api.dev/objects")
            if response.status_code == 200:
                return {
                    "statusCode": 200,
                    "body": json.dumps({"externalData": response.json()})
                }
            else:
                return {
                    "statusCode": response.status_code,
                    "body": json.dumps({"message": "Failed to fetch external data."})
                }
        except Exception as e:
            return {
                "statusCode": 500,
                "body": json.dumps({"message": "Error making external API call.", "error": str(e)})
            }
    else:
        return {
            "statusCode": 404,
            "body": json.dumps({"message": "Route not found"})
        }
