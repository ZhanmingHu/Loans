/*OppLoans SQL*/
-- Query 1 Count the number of loans per customer
select count(*)
from all_loans
group by custid;

-- Query 2 if a customer had more than one loan at the same time
select custid
from all_loans
group by custid
having count(*) >1;

-- Query 3a how much payment is received from each customer in the 1st 6months of being a customer
--       3b what % of principal was collected
select custid, sum(w.amount_paid), sum(w.principal_paid)/sum(a.amount)
from all_loans a, all_loanhist w
where a.loanid = w.loanid and TIMESTAMPDIFF(MONTH, w.eowdate, a.approvedate) < 6 
group by a.custid;

-- Query 4 average rate of missing 1st payment by month of approavedate of loan

Create view ontime as
SELECT month(a.approvedate) as mon,count(distinct a.loanid) as num_ontime
from all_loans a, all_loanhist h
where a.loanid = h.loanid and
h.loanid in (
 SELECT h.loanid
 from all_loans a, all_loanhist h
 where a.loanid = h.loanid 
 group by h.loanid
 having min(h.eowdate) <= date_add(min(a.approvedate), INTERVAL 7 DAY))
group by (select distinct month(a.approvedate)
    from all_loans a, all_loanhist h
                where a.loanid = h.loanid);

Create view entire as
SELECT month(a.approvedate) as mon,count(distinct a.loanid) as num_total
from all_loans a
where a.loanid 
group by (month(a.approvedate));

select b.mon,1- ifnull( a.num_ontime , 0 ) /b.num_total
FROM ontime a
RIGHT JOIN entire b 
ON a.mon = b.mon;


-- Query 5 top3 most profitable customers (percentage of total paid of loan amount)
select a.loanid, sum(w.amount_paid)/a.amount AS prof
from all_loans a, all_loanhist w
where a.loanid = w.loanid
group by loanid
order by prof desc
limit 3;































