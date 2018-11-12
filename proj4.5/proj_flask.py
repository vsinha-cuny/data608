
import pandas as pd
from flask import Flask, jsonify

app = Flask(__name__)

# This is API returns the list of the different types of trees
# found in the Borough passed in in the URL.
# For instance, to see the types of trees found in the Bronx,
# type: http://127.0.0.1:5000/trees/Bronx
# Replace "Bronx" with another Borough name to its corresponding
# information.
@app.route('/trees/<string:word>')
def return_trees(word):
    soql_url = ("https://data.cityofnewyork.us/resource/nwxe-4ae8.json?" +\
                "$select=spc_common,count(tree_id)" +\
                "&$where=boroname=\"" + word + "\"" + 
                "&$group=spc_common").replace(" ", "%20")
    soql_trees = pd.read_json(soql_url)
    return jsonify({word: soql_trees["spc_common"].to_json()})

if __name__ == '__main__':
    app.run(debug=True)
