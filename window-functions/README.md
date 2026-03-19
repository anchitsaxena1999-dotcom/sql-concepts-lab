# 🪟 Window Functions

Window functions perform calculations across a set of rows related to the current row —
without collapsing the result like `GROUP BY` does.

> 💡 Syntax: `function() OVER (PARTITION BY ... ORDER BY ...)`

## 🧠 Window Functions Covered

| Function | Purpose |
|----------|---------|
| `ROW_NUMBER()` | Assigns unique row number per partition |
| `RANK()` | Rank with gaps on ties |
| `DENSE_RANK()` | Rank without gaps on ties |
| `LEAD()` | Access next row's value |
| `LAG()` | Access previous row's value |
| `FIRST_VALUE()` | First value in the window frame |
| `LAST_VALUE()` | Last value in the window frame |
| `SUM() OVER()` | Running or cumulative total |
| `AVG() OVER()` | Rolling or partition average |
| `MAX() OVER()` | Max value across partition |
| `NTILE(n)` | Divide rows into n equal buckets |

---

## 🖼️ Frame Clause Cheatsheet
```sql
-- Default (entire partition)
OVER (PARTITION BY col ORDER BY col)

-- Running total (from start to current row)
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW

-- 7-day rolling window
ROWS BETWEEN 6 PRECEDING AND CURRENT ROW

-- Full partition (needed for LAST_VALUE to work correctly)
ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
```

---

## 💡 Key Concepts to Remember

- **PARTITION BY** → resets the function for each group (like GROUP BY but rows stay)
- **ORDER BY inside OVER()** → defines the sequence for ranking or running totals
- **ROWS BETWEEN** → controls exactly which rows are included in the window frame
- **DENSE_RANK vs ROW_NUMBER** → use DENSE_RANK when ties should both appear, ROW_NUMBER when you want exactly one row
- **LAG / LEAD** → great for month-over-month comparisons and gap detection

---

## 🔗 Follow the LinkedIn Series
Each question above has a detailed post on LinkedIn →
[LinkedIn Profile](https://www.linkedin.com/in/anchitsaxena-analyst/)

---

⭐ Star the repo if this helped you crack your SQL interview!
