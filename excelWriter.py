import json
import pandas as pd

def read_db(filename):
	with open(filename) as f:
		return json.load(f)

def writeExcel(data, filename, sheet):
	df = pd.DataFrame(data)
	df.to_excel(filename, sheet_name=sheet, index=False)

def process_db(json_file):
	data = read_db(json_file)
	recipes = data.get('recipes', [])
	ingredients = data.get('ingredients', [])
	
	with pd.ExcelWriter('received_db.xlsx', engine='openpyxl') as writer:
		writeExcel(ingredients, writer, 'Ingredients')
		writeExcel(recipes, writer, 'Recipes')
		
	print('Wrote data to received_db.xlsx')

def clear_file(filename):
	with open(filename, 'r+') as f:
		f.truncate(0)

if __name__ == "__main__":
	clear_file('received_db.xlsx')
	process_db("SSData.db")
	with open("SSData.db", 'r+') as f:
		f.truncate(0)

