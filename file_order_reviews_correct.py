#!/usr/bin/env python3
import sys

def merge_csv_records(input_file, output_file):
    records = []
    current_record = ""
    
    with open(input_file, 'r', encoding='utf-8') as fin:
        for line in fin:
            line = line.rstrip('\n')
            # Si current_record n'est pas vide, on ajoute un espace pour remplacer le saut de ligne
            if current_record:
                current_record += " " + line
            else:
                current_record = line
            
            temp = current_record.replace('""', '')
            if temp.count('"') % 2 == 0:
                records.append(current_record)
                current_record = ""
    
    if current_record:
        records.append(current_record)
    
    with open(output_file, 'w', encoding='utf-8') as fout:
        for rec in records:
            fout.write(rec + "\n")

if __name__ == "__main__":
    input_file = "olist_order_reviews_dataset.csv"
    output_file = "merged_olist_order_reviews_dataset.csv"
    merge_csv_records(input_file, output_file)
    print(f"Le fichier fusionné a été créé : {output_file}")
