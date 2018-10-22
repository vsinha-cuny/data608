# Data608 Assignment 4
# Vikas K. Sinha
# 21 Oct 2018

import pandas as pd
import numpy as np
import dash
import dash_core_components as dcc
import dash_html_components as html
import plotly.graph_objs as go

csv_file = "2015_Street_Tree_Data_Reduced.csv"
csv_url = "https://raw.githubusercontent.com/vsinha-cuny/data608/master/proj4/" + csv_file
print("Reading csv file ...")
trees = pd.read_csv(csv_url)
print("done.")
tree=trees[["tree_id", "spc_common", "borough", "health", "steward"]].copy()
tree.dropna(inplace=True)
del trees

external_stylesheets = ['https://codepen.io/chriddyp/pen/bWLwgP.css']
app = dash.Dash(__name__, external_stylesheets=external_stylesheets)

def generate_graph(df, max_rows=80):
    x1 = df.health.unique()
    d1 = df[(df.health==x1[0])]
    d2 = df[(df.health==x1[1])]
    d3 = df[(df.health==x1[2])]

    trace1 = go.Scatter(
                        x=d1.borough,
                        y=d1.Count,
                        mode= "markers",
                        name=x1[0],
                        marker= {"size": 12}
                    )

    trace2 = go.Scatter(
                        x=d2.borough,
                        y=d2.Count,
                        mode= "markers",
                        name=x1[1],
                        marker= {"size": 12}
                    )

    trace3 = go.Scatter(
                        x=d3.borough,
                        y=d3.Count,
                        mode= "markers",
                        name=x1[2],
                        marker= {"size": 12}
                    )

    return dcc.Graph(
        id="basic-interaction",
        figure={
            "data": [
                trace1, trace2, trace3
            ]
        }
    )

def generate_table(dataframe, max_rows=80):
    return html.Table(
        # Header
        [html.Tr([html.Th(col) for col in dataframe.columns])] +

        # Body
        [html.Tr([
            html.Td(dataframe.iloc[i][col]) for col in dataframe.columns
        ]) for i in range(min(len(dataframe), max_rows))]
    )

app = dash.Dash()

app.layout = html.Div(children=[
    html.H4(children='Health of Trees in New York Boroughs'),
    dcc.Dropdown(id='dropdown', options=[
        {'label': i, 'value': i} for i in tree.spc_common.unique()
    ], multi=False, placeholder='Filter by species ...'),
    html.Table(id='table-container')
])

@app.callback(
    dash.dependencies.Output('table-container', 'children'),
    [dash.dependencies.Input('dropdown', 'value')])
def display_table1(dropdown_value):
    if dropdown_value is None:
        return generate_table(tree)
    dff = tree[tree.spc_common.str.contains('|'.join(dropdown_value))]
    dff2 = dff[dff.steward != "None"]
    d2 = pd.DataFrame({"Count": dff.groupby(["health", "borough"]).size()}).reset_index()
    d3 = pd.DataFrame({"Count": dff2.groupby(["health", "borough"]).size()}).reset_index()
    return generate_graph(d2)

app.css.append_css({"external_url": "https://codepen.io/chriddyp/pen/bWLwgP.css"})

if __name__ == '__main__':
    app.run_server(debug=True)

