from cryptocmd import CmcScraper
import pandas as pd
import numpy as np
from functools import reduce
import requests
from datetime import datetime, timedelta
import time
import json
import csv

def collect_data(crypto, start_date, end_date):
  collect = {}
  for i in crypto:
    scraper = CmcScraper(i)
    df = scraper.get_dataframe()[["Date", "Close", "Market Cap"]]
    df["Symbol"] = i
    df["Log Returns"] = np.log(df['Close'] / df['Close'].shift(-1))
    df = df.loc[(df["Date"] >= start_date) & (df["Date"] <= end_date)]
    collect.update({i: df})
  return collect


def weighted_portfolio(portfolio, weight):
  # create reduced portfolio with only Date, Log Returns and Closing price/ Market Cap
  portfolio_s = {
    k: v[["Date", "Log Returns", weight]]
    for k, v in portfolio.items()
  }

  # add currency suffixes
  portfolio_s_renamed = {
    k: v.rename(lambda column: column + '_' + k
                if column != "Date" else "Date",
                axis='columns')
    for k, v in portfolio_s.items()
  }

  # merge dataframes
  final_df = reduce(
    lambda left, right: pd.merge(left, right, on=['Date'], how='outer'),
    portfolio_s_renamed.values())

  # create column with the total sum of weights
  columns = [weight + "_" + i for i in crypto]
  final_df[weight + "_TOTAL"] = final_df[columns].sum(axis=1)

  # create columns Weighted Returns = Log Return_X * Weight_X/ Weight TOTAL
  for i in crypto:
    final_df["Weighted Returns_" + i] = final_df[weight + "_" + i] / final_df[
      weight + "_TOTAL"] * final_df["Log Returns_" + i]

  # create column with the total sum of the weighted returns
  columns_r = ["Weighted Returns_" + i for i in crypto]
  final_df["Weighted Returns_Final"] = final_df[columns_r].sum(axis=1)

  weighted_returns = final_df['Weighted Returns_Final'].tolist()
  dates = final_df['Date'].tolist()
  print(final_df)
  return dates,weighted_returns

with open('CODE/top20index_code/top20crypto.txt', 'r') as file:
    top20 = json.load(file)

returns = {}

for date, crypto in top20.items():
  date_obj = datetime.strptime(date, '%Y-%m-%d')
  new_date = date_obj + timedelta(days=6)
  end_date = new_date.strftime('%Y-%m-%d')
  portfolio = collect_data(crypto, date, end_date)
  dates, market_portfolio = weighted_portfolio(portfolio, "Market Cap")
  market_portfolio.reverse()
  dates.reverse()
  formatted_timestamps = []
  # Loop through each timestamp and format it as a string with the desired format
  for timestamp in dates:
    formatted_timestamps.append(timestamp.strftime('%Y-%m-%d'))
  returns_dic = dict(zip(formatted_timestamps, market_portfolio))
  returns.update(returns_dic)
  time.sleep(10)

with open('topXY.txt', 'w') as file:
    json.dump(returns, file)
