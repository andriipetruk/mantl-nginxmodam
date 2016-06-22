#!flask/bin/python
from flask import Flask, jsonify
import json
from urllib2 import Request, build_opener, HTTPCookieProcessor, HTTPHandler
import cookielib


app = Flask(__name__)


def get_group(tocken):


    url + ""
    headers = {"Content-type": "application/json",
        "iplanetDirectoryPro": openam.id }
    response = requests.post(url, json.dumps(data), headers=headers)
    response.close()
    openam_answer = response.json()


def appjson_with_owner(request, group):
    request.append({'labels':group})
    return request

@app.route('/v2/apps/', methods=['POST'])
def create_apps():
    if not request.json or not 'title' in request.json:
        abort(400)
    appjson_with_owner = add_labal(request.json)

    return appjson_with_owner

if __name__ == '__main__':
    app.run(debug=True)
