#!/usr/bin/python

#Import packages
import datetime as dt
from datetime import timedelta

# Define a function to generate timechunks
def define_dates(as_of_date,days_before_as_of_date,days_after_as_of_date):
    """
    Defines snapshots based of the end of training period
    
    Args:
        as_of_date(date): The reference date. It corresponds to end of training and beginning of test
        days_of_before_as_of_date(Int): Quantity of dates before as of date, it sets the beginning of training period
        days_after_as_of_date(int): Quantity of dates after as_of_date, it sets the ending of test period
    """
    as_of_date = dt.datetime.strptime(as_of_date, '%Y-%m-%d %H:%M:%S')
    snapshot_beginning = as_of_date - dt.timedelta(days_before_as_of_date)
    snapshot_end = as_of_date
    snapshot_end_target_period = as_of_date + timedelta(days_after_as_of_date)
    return (snapshot_beginning,snapshot_end,snapshot_end_target_period)



