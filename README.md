# Expense Tracker

A Flutter app to manage daily income and expenses with a local SQLite database.

## Features
- Dashboard with Total Income, Total Expense and Current Balance
- Add, view, update and delete transactions
- Form validation (title, amount, category, type)
- Date picker, category dropdown, income/expense type selector
- Transaction list built with `ListView.builder`, colour-coded by type
- Search and filter on the All Transactions screen
- Delete confirmation with `AlertDialog`
- Data saved offline with `sqflite` (`expense_tracker.db`, table `transactions`)

## Tech stack
Flutter, Dart, sqflite, provider, intl

## Run locally