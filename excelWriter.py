import json
import re
import os
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

def extractData(excel_file):
	if not os.path.exists(excel_file):
		print("Excel File Not Found.")
		return
	try:
		ingredient_data = pd.read_excel(excel_file, 'Ingredients')
		recipe_data = pd.read_excel(excel_file, 'Recipes')
	except Exception as e:
		print(f"Failed to read Excel file: {str(e)}")
		return
	
	results = []
	for idx, row in recipe_data.iterrows():
		recipe_name = row['name']
		steps = row['steps']
		pattern = re.compile(r'\.\s*(?=[A-Z])|\.$')
		step_list = pattern.split(steps)
		classifications = row['classification']
		measure_nums = []
		class_list = []
		class_idx = 0
		for c in classifications.split(","):
			class_list.append(c)
		for step in step_list:
			print(step)
			step = step.strip()
			num = re.findall(r'[-+]?[0-9]*\.?[0-9]+', step)
			if num:
				measure_nums.append(num[0])
			else:
				measure_nums.append(" ")
			
		results.append({
			'Recipe Name': recipe_name,
			'Steps': step_list,
			'Classifications': class_list,
			'Measurement Numbers': measure_nums
		})

	return results
			
def clear_file(filename):
	with open(filename, 'r+') as f:
		f.truncate(0)
	
if __name__ == "__main__":
	clear_file('received_db.xlsx')
	process_db("SSData.db")
	with open("SSData.db", 'r+') as f:
		f.truncate(0)
	res = extractData("received_db.xlsx")
	print(res)

