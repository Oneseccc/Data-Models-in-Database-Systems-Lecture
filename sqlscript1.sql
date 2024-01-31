REM   Script: pw2
REM   data models pw2

create type people as object ( 
    id_number			int, 
    full_name			varchar2(30) 
) not final;
/

create type organizer_type under people ( 
    organizer_company	varchar2(30) 
); 

/

create table organizers of organizer_type;

create type ticket_type as object( 
    ticket_id			int, 
    seat_type			char, 
    base_price			number, 
    coefficient			number, 
    member function ticket_price return number 
);
/

create type tickets_nt as table of ticket_type; 

/

create type event_type as object ( 
    event_id			int, 
    event_name			varchar2(60), 
    event_date			date, 
    cost				number, 
    tickets				tickets_nt, 
    organizer			ref organizer_type, 
    member function event_status return varchar2, 
    map member function next_event_cost return number 
);
/

create table events of event_type( 
    constraint PK_events primary key (event_id) 
) nested table tickets store as tickets;

create type customer_type under people ( 
    customer_email		varchar2(60), 
    sub_level			char,			 -- f for free, s for silver, g for gold, v for vip 
    tickets				tickets_nt, 
    member function subscription_price return number 
);
/

create table customers of customer_type ( 
    constraint PK_customers primary key (id_number) 
)nested table tickets store as tickets_nested;

create sequence id_seq start with 1 increment by 1;

create or replace type body ticket_type as 
	member function ticket_price return number is 
    	begin 
    		if seat_type = 'A' then 
    			return base_price; 
    		elsif seat_type = 'B' then 
    			return base_price * coefficient; 
			else 
                return -1; 
    		end if; 
    	end ticket_price; 
	end;
/

create or replace type body customer_type as 
	member function subscription_price return number is 
		begin 
			case sub_level 
				when 'f' then 
					return 0; 
				when 's' then 
					return 40; 
				when'g' then 
					return 70; 
				when 'v' then 
					return 100; 
				else 
					return -1; 
			end case; 
		end subscription_price; 
	end; 

/

create or replace type body event_type as 
    map member function next_event_cost return number is 
        v_next_event_cost number; 
		begin 
            select cost 
            into v_next_event_cost 
            from events 
            where event_date > self.event_date 
			order by event_date 
            fetch first 1 row only; 
 
			return v_next_event_cost; 
 
    		exception 
                when no_data_found then 
                	return null; 
		end next_event_cost; 
 
	member function event_status return varchar2 is 
		begin 
			if event_date > sysdate then 
				return 'The event has not happened yet'; 
			elsif event_date < sysdate then 
				return 'The event had already happened'; 
			else 
				return 'The event takes place today'; 
			end if; 
		end event_status; 
	end;
/

insert into customers values (id_seq.nextval, 'Jamila Rahimova', 'jamila.rahimova@gmail.com', 'v', tickets_nt(ticket_type(id_seq.nextval, 'A', 100.00, 1.5)));

insert into customers values (id_seq.nextval, 'Leyla Rahimova', 'leyla.rahimova@gmail.com', 'f', tickets_nt(ticket_type(id_seq.nextval, 'B', 80.00, 1.5), ticket_type(id_seq.nextval, 'B', 80.00, 1.5)));

insert into customers values (id_seq.nextval, 'Hasan Enes Turan', 'hasanenes.turan@gmail.com', 's', null);

insert into customers values (id_seq.nextval, 'Muslim Berat Canpolat', 'muslimberat.canpolat@gmail.com', 'g', tickets_nt(ticket_type(id_seq.nextval, 'A', 40.00, 2.0), ticket_type(id_seq.nextval, 'B', 30.00, 2.0)));

insert into customers values (id_seq.nextval, 'Jack Sparrow', 'jack.sparrow@gmail.com', 'g', tickets_nt(ticket_type(id_seq.nextval, 'B', 120.00, 1.0), ticket_type(id_seq.nextval, 'B', 40.00, 2.0)));

insert into customers values (id_seq.nextval, 'Captain America', 'captain.america@gmail.com', 'v', tickets_nt(ticket_type(id_seq.nextval, 'B', 90.00, 1.0)));

insert into customers values (id_seq.nextval, 'Super Man', 'super.man@gmail.com', 's', tickets_nt(ticket_type(id_seq.nextval, 'B', 120.00, 1.0)));

insert into customers values (id_seq.nextval, 'Bat Man', 'bat.man@gmail.com', 'f', tickets_nt(ticket_type(id_seq.nextval, 'A', 80.00, 1.5), ticket_type(id_seq.nextval, 'B', 100.00, 1.5), ticket_type(id_seq.nextval, 'A', 30.00, 2.0)));

insert into customers values (id_seq.nextval, 'Jamila Sultanova', 'jamila.sultanova@gmail.com', 'f', null);

insert into customers values (id_seq.nextval, 'Zahra Mammadova', 'zahra.mammadova@gmail.com', 'f', tickets_nt(ticket_type(id_seq.nextval, 'A', 100.00, 1.5)));

insert into customers values (id_seq.nextval, 'Musa Mammadzade', 'musa.mammadzade@gmail.com', 'v', tickets_nt(ticket_type(id_seq.nextval, 'A', 90.00, 1.0)));

insert into customers values (id_seq.nextval, 'Elon Musk', 'elon.musk@gmail.com', 's', tickets_nt(ticket_type(id_seq.nextval, 'B', 30.00, 2.0), ticket_type(id_seq.nextval, 'B', 120.00, 1.0)));

insert into customers values (id_seq.nextval, 'Joe Biden', 'joe.biden@gmail.com', 'g', tickets_nt(ticket_type(id_seq.nextval, 'A', 40.00, 2.0)));

insert into events values (id_seq.nextval, 'Era Tour', to_date('25-12-2023', 'DD-MM-YYYY'), 500.00, tickets_nt(ticket_type(2, 'A', 100, 1.5), ticket_type(19, 'B', 100, 1.5), ticket_type(23, 'A', 100, 1.5)), null);

insert into events values (id_seq.nextval, 'Movie Premiere', to_date('05-09-2023', 'DD-MM-YYYY'), 1800.00, tickets_nt(ticket_type(4, 'B', 80, 1.5), ticket_type(5, 'B', 80, 1.5), ticket_type(18, 'A', 80, 1.5)), null);

insert into events values (id_seq.nextval, 'Art Exhibition', to_date('12-08-2023', 'DD-MM-YYYY'), 840.00, tickets_nt(ticket_type(8, 'A', 40, 2.0), ticket_type(12, 'B', 40, 2.0), ticket_type(30, 'A', 40, 2.0)), null);

insert into events values (id_seq.nextval, 'Tech Summit', to_date('08-01-2024', 'DD-MM-YYYY'), 1000.00, tickets_nt(ticket_type(11, 'B', 120, 1.0), ticket_type(16, 'B', 120, 1.0), ticket_type(28, 'B', 120, 1.0)), null);

insert into events values (id_seq.nextval, 'Basketball Match', to_date('22-06-2023', 'DD-MM-YYYY'), 600.00, tickets_nt(ticket_type(14, 'B', 90, 1.0), ticket_type(25, 'A', 90, 1.0)), null);

insert into events values (id_seq.nextval, 'New Year Eve Concert', to_date('31-12-2023', 'DD-MM-YYYY'), 530.00, tickets_nt(ticket_type(9, 'B', 30, 2.0), ticket_type(20, 'A', 30, 2.0), ticket_type(27, 'B', 30, 2.0)), null);

insert into organizers values (id_seq.nextval, 'Harley Quinn', 'Company 1');

insert into organizers values (id_seq.nextval, 'Julius Caesar', 'Company 2');

insert into organizers values (id_seq.nextval, 'Charles Darwin', 'Company 3');

insert into organizers values (id_seq.nextval, 'Joseph Stalin', 'Company 4');

insert into organizers values (id_seq.nextval, 'Albert Einstein', 'Company 5');

insert into organizers values (id_seq.nextval, 'Marie Curie', 'Company 6');

declare 
	org_ref ref organizer_type; 
begin 
	select ref(o) into org_ref 
	from organizers o 
	where o.organizer_company = 'Company 1'; 
 
	update events o 
    set o.organizer = org_ref 
	where o.event_name = 'Era Tour'; 
end;
/

declare 
	org_ref ref organizer_type; 
begin 
	select ref(o) into org_ref 
	from organizers o 
	where o.organizer_company = 'Company 2'; 
 
	update events o 
    set o.organizer = org_ref 
	where o.event_name = 'Movie Premiere'; 
end; 

/

declare 
	org_ref ref organizer_type; 
begin 
	select ref(o) into org_ref 
	from organizers o 
	where o.organizer_company = 'Company 3'; 
 
	update events o 
    set o.organizer = org_ref 
	where o.event_name = 'Art Exhibition'; 
end; 

/

select e.cost, deref(e.organizer) 
from events e;

select e.tickets, e.event_name, e.event_status(), deref(e.organizer) 
from events e;

declare 
	org_ref ref organizer_type; 
begin 
	select ref(o) into org_ref 
	from organizers o 
	where o.organizer_company = 'Company 4'; 
 
	update events o 
    set o.organizer = org_ref 
	where o.event_name = 'Tech Summit'; 
end; 

/

declare 
	org_ref ref organizer_type; 
begin 
	select ref(o) into org_ref 
	from organizers o 
	where o.organizer_company = 'Company 5'; 
 
	update events o 
    set o.organizer = org_ref 
	where o.event_name = 'Basketball Match'; 
end;
/

declare 
	org_ref ref organizer_type; 
begin 
	select ref(o) into org_ref 
	from organizers o 
	where o.organizer_company = 'Company 6'; 
 
	update events o 
    set o.organizer = org_ref 
	where o.event_name = 'New Year Eve Concert'; 
end;
/

select e.cost, deref(e.organizer) 
from events e;

select e.event_name, deref(e.organizer) 
from events e;

select e.event_name, deref(e.organizer) 
from events e;

select e.event_name, deref(e.organizer) 
from events e;

select e.cost, deref(e.organizer) 
from events e;

select e.event_id, deref(e.organizer) 
from events e;

select e.cost, deref(e.organizer) 
from events e;

select e.cost, deref(e.organizer) 
from events e;

select e.cost, deref(e.organizer) 
from events e;

select e.tickets, deref(e.organizer) 
from events e;

select e.tickets, e.event_name, e.event_status(), deref(e.organizer) 
from events e;

select e.tickets, e.event_name, e.event_status(), deref(e.organizer) 
from events e 
where e.event_date > sysdate;

select e.tickets, e.event_name, e.event_status(), deref(e.organizer) 
from events e 
where e.event_date > sysdate;

create or replace type body ticket_type as 
	member function ticket_price return number is 
    	begin 
    		if seat_type = 'A' then 
    			return base_price; 
    		elsif seat_type = 'B' then 
    			return base_price * coefficient; 
			else 
                return -1; 
    		end if; 
    	end ticket_price; 
	end;
/

create or replace type body customer_type as 
	member function subscription_price return number is 
		begin 
			case sub_level 
				when 'f' then 
					return 0; 
				when 's' then 
					return 40; 
				when'g' then 
					return 70; 
				when 'v' then 
					return 100; 
				else 
					return -1; 
			end case; 
		end subscription_price; 
	end;
/

create or replace type body event_type as 
    map member function next_event_cost return number is 
        v_next_event_cost number; 
		begin 
            select cost 
            into v_next_event_cost 
            from events 
            where event_date > self.event_date 
			order by event_date 
            fetch first 1 row only; 
 
			return v_next_event_cost; 
 
    		exception 
                when no_data_found then 
                	return null; 
		end next_event_cost; 
 
	member function event_status return varchar2 is 
		begin 
			if event_date > sysdate then 
				return 'The event has not happened yet'; 
			elsif event_date < sysdate then 
				return 'The event had already happened'; 
			else 
				return 'The event takes place today'; 
			end if; 
		end event_status; 
	end;
/

describe events


declare 
	org_ref ref organizer_type; 
begin 
	select ref(o) into org_ref 
	from organizers o 
	where o.organizer_company = 'Company 1'; 
 
	update events o 
    set o.organizer = org_ref 
	where o.event_name = 'Era Tour'; 
end;
/

select c.full_name, c.sub_level, c.subscription_price(), t.seat_type, t.base_price, t.coefficient, t.ticket_price() as ticket_price 
from customers c, table(c.tickets) t 
where c.full_name = 'Jamila Rahimova';

select e.event_id, e.event_name, e.event_date, e.cost, value(t) 
from events e, table(e.tickets) t;

create or replace type body ticket_type as 
	member function ticket_price return number is 
    	begin 
    		if seat_type = 'A' then 
    			return base_price; 
    		elsif seat_type = 'B' then 
    			return base_price * coefficient; 
			else 
                return -1; 
    		end if; 
    	end ticket_price; 
	end;
/

create or replace type body customer_type as 
	member function subscription_price return number is 
		begin 
			case sub_level 
				when 'f' then 
					return 0; 
				when 's' then 
					return 40; 
				when'g' then 
					return 70; 
				when 'v' then 
					return 100; 
				else 
					return -1; 
			end case; 
		end subscription_price; 
	end;
/

select value(c), value(t), t.ticket_price(), value(e), e.event_status() 
from customers c, table(c.tickets) t 
join events e on 1 = 1 
where c.sub_level in ('v', 's') and e.event_date > sysdate and exists (select 1 
    																   from events e 
    																   where e.cost < 900) 
order by c.full_name, e.event_date;

