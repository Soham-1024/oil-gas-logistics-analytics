# oil-gas-logistics-analytics
Logistics and supply chain cost analysis built with MySQL, Excel, and Power BI — covering transportation efficiency, inventory turnover, warehouse utilization, and supplier performance.

SQL Layer — abc_logistics

This file (abc_logistics.sql) has everything in one place: the table schema, the data load
statements, and 12 analysis queries. Built for MySQL 8.0.

What you need before running it

The 9 CSV files (Dim_Date, Dim_TransportMode, Dim_Product, Dim_Warehouse, Dim_Supplier,
Dim_Route, Fact_Fuel_Prices, Fact_Shipments, Fact_Inventory_Snapshot) saved somewhere on
your machine

NOW RUN THE QUERY GIVEN IN THE SQL FILE YOU CAN RUN IT AS A WHOLE BUT IT NEEDS SOME CHANGES TO BE DONE
as change the location of the raw files to the path of the raw files where you have saved them
then after running each query export it in csv format and save it.

What each query gives you

1.Inventory turnover by warehouse
2.Transport cost per ton-km, by mode
3a.Average delay by route, ranked
3b.Delay by mode, monsoon months vs the rest of the year
4.Supplier/carrier scorecard
5.Warehouse utilization %, flagged over/under
6.Pareto — which routes account for most of the freight cost
7.Monthly cost trend
8.On-time delivery rate by mode
9.Demurrage cost as a % of transport spend
10.Road shipments that could realistically shift to pipeline

# Ecel layer

Create a proper blank workspace and get all the generated csv imported in dofferent sheets
also make some new sheets namely
1.pivot cost--create a pivot table showing how a single route can cover majority of cost
2.pivot supllier--how some suppliers always cause huge delays leading to higher penalties
3.waterfall--a chart showing the breakdown of total logistic cost where demurrage is the max amongst all
4.what if mode shift--how mode shift in the route to avoid delays can affect the total cost

# Power BI layer

Firstly import all the raw data CSVs.
create a star like diagram where the facts data is at the centre and the rest as the points around it, wire up all the data as required according to the foreign keys used.

create a dashboard showing 5 types of KPI at the top and some charts for the analysis of the whole data 

refer to the images attached.
