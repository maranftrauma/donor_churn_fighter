#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Aug  4 19:56:42 2019

@author: Maria Ines Aran
"""
import os
os.chdir('/Users/mac/Documents/Wingu/donaronline/trabajo_final_boosteado/churn_donations/data/etl')
from create_dates import define_dates
from create_fold import create_fold
from tqdm import tqdm
from sqlalchemy import create_engine
import datetime as dt

# Connect to db
db_string = 'postgresql://postgres:123456@localhost:5432/donaronline_boosted'
con = create_engine(db_string)

# Get min and max dates in the database
query = """
select 
    date(min(created_at)) min_date,
    date(max(created_at)) max_date
from
    raw.donations
"""
result = con.execute(query)
for row in result:
    min_date = row.min_date
    max_date = row.max_date
    

# Set the quantity of days before and after as_of_date
days_before_as_of_date = 90
days_after_as_of_date = 60

# List of as_of_dates
first_date = min_date + dt.timedelta(days_before_as_of_date + 1)
last_date = max_date - dt.timedelta(days_after_as_of_date - 1)
date = first_date
dates = [date]

while date < last_date:
    date = (date + dt.timedelta(days_after_as_of_date))
    dates.append(date)

dates = [date.strftime('%Y-%m-%d %H:%M:%S') for date in dates]
    
total = len(dates)

with tqdm(total = total) as pbar:
    for i,date in enumerate(dates):
        
        # Define snapshot and number of fold
        snapshot_beginning,snapshot_end,snapshot_end_target_period = define_dates(as_of_date = date,
                                                                                  days_before_as_of_date = days_before_as_of_date,
                                                                                  days_after_as_of_date = days_after_as_of_date)

        # Create fold
        create_fold(snapshot_beginning = snapshot_beginning,
                    snapshot_end = snapshot_end,
                    snapshot_end_target_period = snapshot_end_target_period, 
                    fold_number = i)
        
        # tqdm progress bar 
        pbar.update(1)
