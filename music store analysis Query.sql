
# QUESTION SET 1 : EASY LEVEL
# Q1: Who is the senior most employee based on job title?

select employee_id,title,first_name,last_name,levels from employee
order by levels desc
limit 1;

# Q2: which contries have most invoices?

select count(*) as total_invoices, billing_country
from invoice
group by billing_country
order by total_invoices desc;

#Q3: What is Top 3 values of total invoices? 

select total from invoice
order by total desc
limit 3;

#Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
-- Write a query that returns one city that has the highest sum of invoice totals. 
-- Return both the city name & sum of all invoice totals

select billing_city, sum(total) as total_invoice
from invoice
group by billing_city
order by total_invoice desc
limit 1;

#Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money.

select customer.customer_id, first_name, country, SUM(invoice.total) as total
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id, first_name, country
order by total desc
limit 1;

#  QUESTION SET 2 : MODERATE LEVEL

# Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A.

# Method 1:-

select distinct customer.email,customer.first_name,customer.last_name
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice_line.invoice_id=invoice.invoice_id
where track_id in (
                select track_id from track
                join genre on genre.genre_id=track.genre_id
                where genre.name like 'Rock')
order by email;

# Method 2 :-
select distinct customer.email,customer.first_name,customer.last_name
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_line_id
join track on track.track_id=invoice_line.track_id
join genre on genre.genre_id=track.genre_id
where genre.name like 'Rock'
order by customer.email;

# Q2: Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands.

select artist.name,artist.artist_id,count(artist.artist_id) as number_of_songs
from artist
join album2 on album2.artist_id = artist.artist_id
join track on track.album_id= album2.album_id
join genre on genre.genre_id=track.genre_id
where genre.name like 'Rock'
group by artist.name,artist_id
order by number_of_songs desc
limit 10;

# Q3: Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.

select name,milliseconds
from track
where milliseconds > (select avg(milliseconds) as avg_song_length from track)
order by milliseconds desc;

# QUESTION SET 3 - ADVANCE LEVEL

# Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent 

with best_selling_artist as (
						select artist.artist_id as artist_ID, artist.name as artist_name,
                        sum(invoice_line.quantity*invoice_line.unit_price) as Total_sale
						from invoice_line
						join track on track.track_id=invoice_line.track_id
						join album2 on album2.album_id = track.album_id
						join artist on artist.artist_id= album2.artist_id
						group by artist_ID,artist_name
						order by Total_sale desc
                        limit 1
					
                        )

select c.customer_id,c.first_name,c.last_name,bsa.artist_name ,sum(invoice_line.quantity*invoice_line.unit_price) as amount_spent
from customer c
join invoice on invoice.customer_id= c.customer_id
join invoice_line on invoice_line.invoice_id=invoice.invoice_id
join track on track.track_id=invoice_line.track_id
join album2 on album2.album_id=track.album_id
join best_selling_artist bsa on bsa.artist_id = album2.artist_id
group by  c.customer_id,c.first_name,c.last_name,bsa.artist_name  
order by amount_spent desc;

# Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
-- with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
-- the maximum number of purchases is shared return all Genres. 

with popular_music_genre as (
							select count(invoice_line.quantity) as purchased , customer.country,genre.name,genre.genre_id,
                            row_number() over(partition by customer.country order by count(invoice_line.quantity) desc) as rowno
                            from invoice_line
                            join invoice on invoice_line.invoice_id = invoice.invoice_id
                            join customer on customer.customer_id = invoice.customer_id
                            join track on track.track_id= invoice_line.track_id
                            join genre on genre.genre_id = track.genre_id
                            group by customer.country,genre.name,genre.genre_id
                            order by customer.country asc, purchased desc
                            )

select * from popular_music_genre where rowno<=1;

# Q3: Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount.

with customer_with_country as (
							   select customer.customer_id,customer.first_name,customer.last_name,invoice.billing_country,
                               sum(invoice.total) as total_spending,
                               row_number() over(partition by billing_country order by sum(total) desc ) as row_no
                               from invoice
                               join customer on customer.customer_id= invoice.customer_id
                               group by customer.customer_id,customer.first_name,customer.last_name,invoice.billing_country
                               order by customer.customer_id asc,total_spending desc
                               )
select * from customer_with_country where row_no<=1;

