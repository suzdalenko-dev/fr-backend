from datetime import datetime, date, timedelta
from dateutil.relativedelta import relativedelta

def invoices_list_of_current_month():
    today = date.today()
    start_date = today.replace(day=1) - relativedelta(months=12)  # hace 12 meses exactos

    month_ranges = []
    year = start_date.year
    month = start_date.month

    while date(year, month, 1) <= today:
        first_day = date(year, month, 1)

        # calculate last day of the month
        if month == 12:
            last_day = date(year, month, 31)
        else:
            next_month = date(year, month + 1, 1)
            last_day = next_month - timedelta(days=1)

        month_ranges.append((first_day.strftime('%Y-%m-%d'), last_day.strftime('%Y-%m-%d')))

        # move to next month
        if month == 12:
            month = 1
            year += 1
        else:
            month += 1

    return month_ranges


x = invoices_list_of_current_month()

print(x)