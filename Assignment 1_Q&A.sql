######## MySQL Assignment (50 points) ########



#### Question 1 (5 points) ####

## Please fetch the following columns from the "invoices" table:
##
##  - Invoice_Number        (The "invoice_number" column)
##  - Invoice_Total         (The "invoice_total" column)
##  - Payment_Credit_Total  ("payment_total" + "credit_total")
##  - Balance_Due           ("invoice_total" - "payment_total" - "credit_total")
##
## Please only return invoices that have a balance due that is greater than $50.
## Please also sort the result set by balance due in descending order and return only the rows with the 5 largest balance due.

### Answer:-

SELECT 
	Invoice_number, Invoice_total, payment_total, credit_total,		## For Clarity, we will also look at the original columns- 'payment_total' and 'credit_total'
    (payment_total + credit_total) AS Payment_Credit_Total,
    (invoice_total - payment_total - credit_total) AS Balance_Due 
FROM
	invoices
HAVING 				
	Balance_Due > 50  		## Due to the aggregation we use 'HAVING' Clause here, otherwise 'WHERE' clause could be used,
							 # and in that case we had to rewrite the aggregation for 'Balance_Due' instead of using the Alias.
ORDER BY
	Balance_Due DESC LIMIT 5;
    
    
#### Question 2 (5 points) ####

## Please identify all contact persons in the "vendors" table that satisfy the following criteria.
## Please return only the contact persons whose last name begins with the letter A, B, C or E.
## Please sort the result set by last name and then first name in ascending order.

### Answer:-

SELECT 
	vendor_id, vendor_name, vendor_contact_last_name, vendor_contact_first_name		## For clarity, we also will look at the 'vendor_id' 
																					# and 'vendor_name', just to make more sense.
FROM 
	vendors
WHERE
	vendor_contact_last_name LIKE 'A%' OR
    vendor_contact_last_name LIKE 'B%' OR
    vendor_contact_last_name LIKE 'C%' OR
    vendor_contact_last_name LIKE 'E%' 
ORDER BY
	vendor_contact_last_name ASC,	## By default, this one is sorted in Ascending order anyways. But for Clarity we still show it here.
    vendor_contact_first_name ASC;
    
	
#### Question 3 (5 points) ####

## Please identify, for each vendor, the invoices with a non-zero balance due.
##
## Please return the following columns in the result set:
##
##  - Vendor_Name     (The "vendor_name" column from the "vendors" table)
##  - Invoice_Number  (The "invoice_number" column from the "invoices" table)
##  - Invoice_Date    (The "invoice_date" column from the "invoices" table)
##  - Balance_Due     ("invoice_total" - "payment_total" - "credit_total")
##
## The result set should also be sorted by "vendor_name" in ascending order.
    
### Answer:-

SELECT 
	vendors.vendor_name, 	## Since we will join two tables, we need to define the source of the common column.
    invoice_number, invoice_date, 
	(invoice_total - payment_total - credit_total) AS Balance_Due
FROM
	invoices
		INNER JOIN			## Join type declaration
	vendors 
		ON 
	invoices.vendor_id = vendors.vendor_id		## Defining join condition
HAVING  
	Balance_Due > 0      ## Here, we filtered the data as we are interested only in positive 'Balance_Due'.
ORDER BY
	vendor_name ASC;	## By default, this one is sorted in Ascending order anyways. But for Clarity we still show it here.

    
#### Question 4 (5 points) ####

## Please return one row for each vendor, which contains the following values:
##
##  - Vendor_Name  (The "vendor_name" column from the "vendors" table)
##  - The number of invoices (from the "invoices" table) for the vendor
##  - The sum of "invoice_total" (from the "invoices" table) for the vendor
##
## Please sort the result set such that the vendor with the most invoices appears first.

### Answer:-

SELECT 
	vendors.vendor_id, vendor_name,		## Since we will join two tables, we need to define the source of the common column.
										## For clarity, we will also look at 'vendor_id'. Also, as a Primary Key this will help us in later statge.
    SUM(invoices.invoice_total) AS invoice_total,  ## Creating Alias.
	COUNT(invoice_number) AS InvoiceCount  	## Specifying a clolumn in Count will count the number of invoices under each vendor excluding any Null value.
								## We want to see the count result under the created Alias column.
FROM
	vendors
		LEFT JOIN
	invoices 
		ON 
	vendors.vendor_id = invoices.vendor_id 
GROUP BY
	vendors.vendor_id
ORDER BY
	InvoiceCount DESC;  ## We sort the result in Descedning order to get the greater values appered first.
	

#### Question 5 (5 points) ####

## Please return one row for each general ledger account, which contains the following values:
##
##  - Account Number (The "account_number" column from the "general_ledger_accounts" table)
##  - Account Description  (The "account_description" column from the "general_ledger_accounts" table)
##  - The number of items in the "invoice_line_items" table that are related to the account
##  - The sum of "line_item_amount" of the account
##
## Please return only those accounts, whose sum of line item amount is great than $5,000.
## The result set should also be sorted by the sum of line item amount in descending order.

### Answer:-

SELECT 
	gla.account_number AS AC_Num,  		## 'gla' is an Alias created below. We also are creating othe Aliases to be used later
										## Since we will join two tables, we need to define the source of the common column.
    gla.account_description,
    SUM(i.line_item_amount) AS Sum_LItmA,
    COUNT(*) AS Num_Itm
FROM
	general_ledger_accounts AS gla
		INNER JOIN
	invoice_line_items i ON gla.account_number = i.account_number
GROUP BY 
	AC_Num
HAVING 
	Sum_LItmA > 5000
ORDER BY
	Sum_LItmA DESC;
    

#### Question 6 (5 points) ####

## Please identify all invoices, whose payment total is greater than the average payment total
## of all the invoices with a non-zero payment total.
##
## Please return the "invoice_number", "invoice_total", "payment_total" for each invoice satisfying the given criteria.
## Please also sort the result set by "invoice_total" in descending order.

### Answer:-

SELECT   ## This is the Outer query and we have a Subquery below.
	invoice_id, invoice_number, invoice_total, payment_total      ## Additionally, for clarity we will also look at 'invoice_id'.
FROM
	invoices
WHERE
	payment_total > (SELECT 		## This part is the Inner query.
						AVG(payment_total)  
					FROM invoices) AND		## We use AND operator as both the conditions have to be fulfilled.
    payment_total > 0	  
ORDER BY
	invoice_total DESC;

     
#### Question 7 (15 points) ####

## Please identify the accounts (from the "general_ledger_accounts" table),
## which do not match any invoice line items in the "invoice_line_items" table.
##
## Please return the following two columns in the result set:
##
##  - "account_number" (from the "general_ledger_accounts" table)
##  - "account_description" (from the "general_ledger_accounts" table)
##
## Please also sort the result set by account number in ascending order.

## NOTE: You must present THREE different methods in your answer. Please write one query for each method used.

### Answer:-

## Method 01: LEFT JOIN 

SELECT 
	gla.account_number, account_description
FROM
	general_ledger_accounts gla
		LEFT JOIN
	invoice_line_items i 
		ON
	gla.account_number = i.account_number
WHERE
	invoice_id IS NULL 		## This will return the results that did not match during the joining.
ORDER BY
	account_number ASC;			## By default, this one is sorted in Ascending order anyways. But for Clarity we still show it here.
	
## Method 02: RIGHT JOIN  

SELECT 
	gla.account_number, account_description
FROM
	invoice_line_items i
		RIGHT JOIN
	general_ledger_accounts gla
		USING			## Instead of ON operator, we can also use this USING operator.
	(account_number)
WHERE
	invoice_id IS NULL 		## This will return the results that did not match during the joining.
ORDER BY
	account_number ASC;			## By default, this one is sorted in Ascending order anyways. But for Clarity we still show it here.

## Method 03: SUB QUERY and NOT IN  

SELECT 		## Outer query
	account_number, account_description
FROM
	general_ledger_accounts
WHERE
	account_number 
		NOT IN
			(SELECT		## Inner query
				account_number
			FROM
				invoice_line_items)
ORDER BY
	account_number ASC;   		## By default, this one is sorted in Ascending order anyways. But for Clarity we still show it here.



#### Question 8 (5 points) ####

## Please return one row per vendor, which includes the information on the vendor's oldest invoice (the one with the earliest date).
## Note that each vendor's oldest invoice is unique.
##
## Each row returned should include the following values:
##
##  - "vendor_name"
##  - "invoice_number"
##  - "invoice_date"
##  - "invoice_total"
##
## Please sort the result set by "vendor_name" in ascending order.

### Answer:-

SELECT   	## This is the Outer query
	v.vendor_id, vendor_name,   	## 'v' is an Alias created below. Since we will join two tables, we need to define the source of the common column.
									## For Clarity, we will also retrieve 'vendor_id'. 
    invoice_id, invoice_number, invoice_date AS 'Vendor\'s OldestInvoice Date', invoice_total  		
								  ## For Clarity, we will also retrieve 'invoice_id'.
FROM
	vendors v		## Indicating for joining while creating Alias
		INNER JOIN  ## Join type declaration
	invoices i 
		ON
	v.vendor_id = i.vendor_id  ## Defining join condition
WHERE
	invoice_date = (SELECT 			## This is a subquery
						MIN(invoice_date)
					FROM
						invoices
					WHERE 
						vendor_id = v.vendor_id)	## As a 'Correlated subquery', defining the same columns from both, the 'Inner query' and the 'Outer query'.	
ORDER BY
	vendor_name ASC;   ## By default, this one is sorted in Ascending order anyways. But for Clarity we still show it here.
