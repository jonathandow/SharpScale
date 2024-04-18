import json
import re
import pandas as pd

def read_db(filename):
	with open(filename) as f:
		return json.load(f)

def writeExcel(data, filename, sheet):
	df = pd.DataFrame(data)
	df.to_excel(filename, sheet_name=sheet, index=False)
	
def classification(steps):
	print(steps)
	pattern = re.compile(r'\.\s*(?=[A-Z])|\.$')
	step_list = pattern.split(steps)
	c = []

	for step in step_list:
		step = step.strip()
		if step:
			print(step)
			print("\n")
			if re.search(r'\d', step):
				print("Contains number\n")
				c.append("1")
			else:
				c.append("0")
		
	return ", ".join(c)

def process_db(json_file):
	data = read_db(json_file)
	recipes = data.get('recipes', [])
	ingredients = data.get('ingredients', [])
	r_names = [recipe['name'] for recipe in recipes]
	for recipe in recipes:
		recipe['classification'] = classification(recipe.get('steps', ''))
	 
	
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

