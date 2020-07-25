/* SQL QUERIES FOR DATA ANALYST SQL CHALLENGE */

--Question 1
SELECT COUNT(*) FROM users;
/* This command returns the number of users wave has */

--Question 2
SELECT COUNT(transfer_id) FROM transfers
WHERE send_amount_currency = 'CFA';
/* This command will return the number of transfers that have
been sent in the currency CFA */

--Question 3
SELECT DISTINCT COUNT(u_id) FROM transfers
WHERE send_amount_currency = 'CFA';
/* This distinct count function returns only the users
that have sent a transfer in CFA currency */

--Question 4
SELECT TO_CHAR( TO_DATE( EXTRACT(month FROM when_created):: TEXT, 'MM'), 'Month') AS Months,
COUNT(atx_id) FROM agent_transactions WHERE EXTRACT(year FROM when_created) = 2018
GROUP BY EXTRACT(month FROM when_created);
/* In order to obtain the breakdown of the number of agent_transactions in 2018 by months,
the TO_CHAR function will convert the numeric month values to string values */

--Question 5
SELECT SUM(case when amount > 0 THEN amount ELSE 0 END) AS withdrawal,
SUM(CASE WHEN amount < 0 then amount ELSE 0 END) AS deposit,
CASE WHEN ((sum(case when amount > 0 THEN amount else 0 END)) > ((sum(case when amount < 0 then amount else 0 END))) * -1)
then 'withdrawer' else 'depositer' END AS agent_status, COUNT(*) FROM agent_transactions
WHERE agent_transactions.when_created  BETWEEN (now()  - '7 days'::INTERVAL) AND now();
/* This is a very complex one. The goal is to present a count of how many Wave agents
were “net depositors” vs. “net withdrawers" */

--Question 6
CREATE TABLE atx_volume_city_summary AS
SELECT agents.city, COUNT(atx_id) AS atx_volume FROM agent_transactions
INNER JOIN agents ON agents.agent_id = agent_transactions.agent_id
WHERE agent_transactions.when_created > current_date -INTERVAL '7 days'
GROUP BY city;
/* I built the atx_volume_city_summary table by using the CREAT VIEW function,
thereby obtaining city and volume columns */

--Question 7
SELECT agents.country, agents.city, COUNT(atx_id) AS atx_volume FROM agent_transactions
INNER JOIN agents ON agents.agent_id = agent_transactions.agent_id
WHERE agent_transactions.when_created > current_date -INTERVAL '7 days'
GROUP BY country, city;
/* This modified command of the atx_volume_city_summary table now separates the atx volume
by country as well. The columns are now country, city and atx_volume */

--Question 8
CREATE TABLE send_volume_by_country_and_kind AS
SELECT wallets.ledger_location AS country, transfers.kind AS transfer_kind,
SUM(transfers.send_amount_scalar) AS volume
FROM transfers, wallets
WHERE transfers.when_created > CURRENT_DATE - INTERVAL '7 days'
group by ledger_location, kind
/* This command builds a 'send volume by country and kind' table and is grouped by country and kind.
 The country information is obtained from the 'ledger_location' from the wallets table */

--Question 9
SELECT SUM(transfers.send_amount_scalar) AS volume, wallets.ledger_location AS country,
transfers.kind AS transfer_kind,
COUNT(transfers.transfer_id) AS transaction_count,
COUNT(DISTINCT transfers.u_id) AS unique_sender FROM transfers, wallets
WHERE transfers.when_created > CURRENT_DATE - INTERVAL '7 days'
GROUP BY ledger_location, kind, u_id,transfer_id;
/* Here, I modify the send_volume_by_country_and_kind table columns in order to
add transaction counts and number of unique senders*/

--Question 10
SELECT transfers.source_wallet_id, SUM(transfers.send_amount_scalar) AS total_amount_sent
FROM transfers WHERE send_amount_currency = 'CFA'
AND (transfers.when_created > (now() - INTERVAL '10 month'))
GROUP BY transfers.source_wallet_id
HAVING SUM(transfers.send_amount_scalar) > 10000000
/* Grouping the send_amount_scalar by their sum while specifying the CFA currency generates
the total amount sent, and indicates the wallets that have sent more than 10000000 CFA */
