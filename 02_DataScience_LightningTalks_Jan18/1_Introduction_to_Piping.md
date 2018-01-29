### **What is the pipe-operator?**

The pipe operator refers to this set of symbols: %&gt;%  
It allows nesting of many manipulations inside one another. It takes an
object (a dataframe for instance), applies a function to it, and returns
a new dataframe (in the form of a tibble), which you can again pipe into
a new function.

Chaining multiple functions after each other is something you will have
to do frequently in analysis to explore your data, or the wrangle your
data into shape.  
If you need to chain some operations to each other, you have some
options:

1.  You can nest a lot of functions:

<!-- -->

    pizza <- take_out(put_in(dress_with(dress_with
            (dress_with(pie, sauce), oil), cheese), oven), oven)

1.  You can create temporary objects

<!-- -->

    pie_tmp <- dress_with(pie, sauce)
    pie_tmp <- dress_with(pie_tmp, oil)
    pie_tmp <- dress_with(pie_tmp, cheese)
    pie_tmp <- put_in(pie_tmp, oven)
    pizza <- take_out(pie_tmp, oven)

1.  You can build a pipeline of operators using the pipe-operator:

<!-- -->

    pizza <- pie %>% 
      dress_with(sauce) %>% 
      dress_with(oil) %>% 
      dress_with(break(cheese)) %>% 
      put_in(oven) %>%
      take_out(oven)

*Note: i found this non-R example on a blog a while ago, but
unfortunately i did not retain the bloginfo and google does not find it.
So credit for this example goes to someone completely different, but I
don't remember who... * <br>

### **Advantages of using pipes:**

Using pipelines has some advantages: - Structuring sequences of data
operations left-to-right, making it more readable for humans - Avoiding
nested function calls - Minimizing the need for local variables - Making
it easy to add steps anywhere in the sequence of operations if the
output is not entirely what you desired - Making it easy to stepwise
explore someone elses code as you can highlight step by step and run it.

There are some watch-outs in using pipes inside functions and packages
though. If something goes wrong, you can get undecipherable error
messages with very clue on what went wrong. The general advice is to use
temporary variables inside function, which are local anyway and won't
live outside your function.

<br>

**Quick tip: **  
There is a pre-programmed shortcut in Rstudio: Ctlr+Shift+M. I
personally did not find that an easy shortcut to type blindly on either
my Azerty or Qwerty keyboards, so I changed it to Ctlr+P. You can change
shortcuts via Rstudio &gt; Tools &gt; Modify Keyboard Shortcuts.
<br><br>

------------------------------------------------------------------------

The data
========

Kickstarter is a crowdfunding platform which allows creatives to gather
money to complete a project. Project creators have to choose a deadline
and a minimum funding goal.  
The dataset is coming from kaggle:
<https://www.kaggle.com/kemical/kickstarter-projects>

    library(tidyverse)
    #full data
    kickstarter <- readRDS("data/kickstarter.RDS")

    #random sample of 100 rows for the column exploration part
    kickstarter_sample <- sample_n(kickstarter, 100)

    glimpse(kickstarter)

    ## Observations: 378,661
    ## Variables: 12
    ## $ ID            <chr> "1000002330", "1000003930", "1000004038", "10000...
    ## $ name          <chr> "The Songs of Adelaide & Abullah", "Greeting Fro...
    ## $ main_category <chr> "Publishing", "Film & Video", "Film & Video", "M...
    ## $ category      <chr> "Poetry", "Narrative Film", "Narrative Film", "M...
    ## $ date_launched <dttm> 2015-08-11 12:12:28, 2017-09-02 04:43:57, 2013-...
    ## $ date_deadline <dttm> 2015-10-09 11:36:00, 2017-11-01 03:43:57, 2013-...
    ## $ currency      <chr> "GBP", "USD", "USD", "USD", "USD", "USD", "USD",...
    ## $ goal          <dbl> 1000, 30000, 45000, 5000, 19500, 50000, 1000, 25...
    ## $ pledged       <dbl> 0.00, 2421.00, 220.00, 1.00, 1283.00, 52375.00, ...
    ## $ state         <chr> "failed", "failed", "failed", "failed", "cancele...
    ## $ backers       <int> 0, 15, 3, 1, 14, 224, 16, 40, 58, 43, 0, 100, 0,...
    ## $ country       <chr> "GB", "US", "US", "US", "US", "US", "US", "US", ...

<br>

**Pipe example:**

Using a pipeline of functions I can reshape my data into a summary table
of data. This table for instance shows the number of projects, the
percentage of success project, average amount of backers and average
amount of money pledged by category.

    kickstarter %>%
      group_by(main_category) %>%
      summarise(number_of_projects = n(),
                perc_successful = mean(state == "successful"),
                avg_backers = mean(backers),
                avg_pledged = mean(pledged)) %>%
      arrange(desc(perc_successful))

    ## # A tibble: 15 x 5
    ##    main_category number_of_projec~ perc_successful avg_backers avg_pledged
    ##    <chr>                     <int>           <dbl>       <dbl>       <dbl>
    ##  1 Dance                      3768           0.620        42.8        3691
    ##  2 Theater                   10913           0.599        47.1        4097
    ##  3 Comics                    10819           0.540       135          6899
    ##  4 Music                     51918           0.466        52.2        3993
    ##  5 Art                       28153           0.409        42.2        3607
    ##  6 Film & Video              63585           0.372        66.0        6363
    ##  7 Games                     35231           0.355       322         21865
    ##  8 Design                    30070           0.351       241         27120
    ##  9 Publishing                39874           0.308        56.0        3639
    ## 10 Photography               10779           0.307        39.7        3665
    ## 11 Food                      24602           0.247        54.2        5340
    ## 12 Fashion                   22816           0.245        61.4        6549
    ## 13 Crafts                     8809           0.240        27.3        2016
    ## 14 Journalism                 4755           0.213        38.3        3218
    ## 15 Technology                32569           0.198       164         22586

<br><br>

------------------------------------------------------------------------

Selecting and manipulating columns
==================================

In the below section we talk how to order, rename, select and manipulate
the columns which you can use in your pipelines. The below examples are
not complete pipes, as they are mainly intended to show the column
features available.  
In some cases I have added a `glimpse()` statement to allow you to see
in an instant which columns are present in the output without scrolling
through a data table.

<br>

### **Re-ordering columns**

You can use the `select()` function (see below) to re-order columns. The
order in which you select them will determine the final order.

    kickstarter_sample %>% 
      select(main_category, category, goal, currency)

    ## # A tibble: 100 x 4
    ##    main_category category          goal currency
    ##    <chr>         <chr>            <dbl> <chr>   
    ##  1 Art           Art            20000   EUR     
    ##  2 Music         Rock           60000   USD     
    ##  3 Music         Punk             150   CAD     
    ##  4 Technology    Apps            5000   AUD     
    ##  5 Music         Faith           3750   USD     
    ##  6 Technology    Technology     25000   EUR     
    ##  7 Design        Graphic Design    50.0 USD     
    ##  8 Film & Video  Animation        350   NOK     
    ##  9 Food          Drinks           100   CAD     
    ## 10 Theater       Theater          650   USD     
    ## # ... with 90 more rows

If you have many columns and you want to bring just a few to the front,
you can finish your select operation by using the `everything()`
statement, which will add all the remaining columns and save a lot of
typing.

    kickstarter_sample %>%
      select(main_category, category, everything()) %>%
      glimpse

    ## Observations: 100
    ## Variables: 12
    ## $ main_category <chr> "Art", "Music", "Music", "Technology", "Music", ...
    ## $ category      <chr> "Art", "Rock", "Punk", "Apps", "Faith", "Technol...
    ## $ ID            <chr> "2001251305", "707106163", "1237249747", "171529...
    ## $ name          <chr> "Positive7 - Werde Teil der Bewegung!", "The Bud...
    ## $ date_launched <dttm> 2016-08-16 23:33:53, 2013-04-02 02:25:07, 2015-...
    ## $ date_deadline <dttm> 2016-09-25 23:33:53, 2013-05-02 02:25:07, 2015-...
    ## $ currency      <chr> "EUR", "USD", "CAD", "AUD", "USD", "EUR", "USD",...
    ## $ goal          <dbl> 20000, 60000, 150, 5000, 3750, 25000, 50, 350, 1...
    ## $ pledged       <dbl> 1.00, 609.00, 4.00, 0.00, 65.00, 744.00, 120.00,...
    ## $ state         <chr> "failed", "canceled", "failed", "failed", "faile...
    ## $ backers       <int> 1, 5, 2, 0, 5, 14, 8, 0, 1, 6, 5, 42, 42, 0, 775...
    ## $ country       <chr> "DE", "US", "CA", "AU", "US", "ES", "US", "NO", ...

<br>

### **Renaming a column**

If you are doing a select statement anyways, you can rename straight in
the `select` function.

    kickstarter_sample %>%
      select(main_category, category, project = name, status = state)

    ## # A tibble: 100 x 4
    ##    main_category category       project                           status  
    ##    <chr>         <chr>          <chr>                             <chr>   
    ##  1 Art           Art            Positive7 - Werde Teil der Beweg~ failed  
    ##  2 Music         Rock           The Buddz Break Out Album and Mu~ canceled
    ##  3 Music         Punk           Stupid Is As Stupid Does!         failed  
    ##  4 Technology    Apps           CITFREE.COM                       failed  
    ##  5 Music         Faith          I won't stay silent               failed  
    ##  6 Technology    Technology     "100% Ecological Lava Lamp - \"E~ failed  
    ##  7 Design        Graphic Design 100s of Logos in 10 Days!         success~
    ##  8 Film & Video  Animation      Samurai Warrior the Anime Series  failed  
    ##  9 Food          Drinks         Exploring Torontos Beer Scene As~ failed  
    ## 10 Theater       Theater        Revolutionary Shorts: Join the C~ success~
    ## # ... with 90 more rows

If you want to retain all columns, you can rename by adding a 'rename'
statement.

    kickstarter_sample %>% 
      rename(project = name, status = state, 
             launch_date = date_launched, deadline = date_deadline) %>%
      glimpse

    ## Observations: 100
    ## Variables: 12
    ## $ ID            <chr> "2001251305", "707106163", "1237249747", "171529...
    ## $ project       <chr> "Positive7 - Werde Teil der Bewegung!", "The Bud...
    ## $ main_category <chr> "Art", "Music", "Music", "Technology", "Music", ...
    ## $ category      <chr> "Art", "Rock", "Punk", "Apps", "Faith", "Technol...
    ## $ launch_date   <dttm> 2016-08-16 23:33:53, 2013-04-02 02:25:07, 2015-...
    ## $ deadline      <dttm> 2016-09-25 23:33:53, 2013-05-02 02:25:07, 2015-...
    ## $ currency      <chr> "EUR", "USD", "CAD", "AUD", "USD", "EUR", "USD",...
    ## $ goal          <dbl> 20000, 60000, 150, 5000, 3750, 25000, 50, 350, 1...
    ## $ pledged       <dbl> 1.00, 609.00, 4.00, 0.00, 65.00, 744.00, 120.00,...
    ## $ status        <chr> "failed", "canceled", "failed", "failed", "faile...
    ## $ backers       <int> 1, 5, 2, 0, 5, 14, 8, 0, 1, 6, 5, 42, 42, 0, 775...
    ## $ country       <chr> "DE", "US", "CA", "AU", "US", "ES", "US", "NO", ...

<br>

### **Selecting columns by their full name**

To select a few columns just add their names in the select statement.
The order in which you code them, will determine the order in which they
appear in the output - unless you create summary functions later on.

    kickstarter_sample %>%
      select(main_category, state, name)

    ## # A tibble: 100 x 3
    ##    main_category state      name                                          
    ##    <chr>         <chr>      <chr>                                         
    ##  1 Art           failed     Positive7 - Werde Teil der Bewegung!          
    ##  2 Music         canceled   The Buddz Break Out Album and Music Video (Ca~
    ##  3 Music         failed     Stupid Is As Stupid Does!                     
    ##  4 Technology    failed     CITFREE.COM                                   
    ##  5 Music         failed     I won't stay silent                           
    ##  6 Technology    failed     "100% Ecological Lava Lamp - \"Elava Lamp\""  
    ##  7 Design        successful 100s of Logos in 10 Days!                     
    ##  8 Film & Video  failed     Samurai Warrior the Anime Series              
    ##  9 Food          failed     Exploring Torontos Beer Scene As A Broke Coll~
    ## 10 Theater       successful Revolutionary Shorts: Join the Cause          
    ## # ... with 90 more rows

If want to add a lot of columns, it can save a lot of space to have a
good look at your data and see whether you can't get to your selection
by using chunks, deselecting or even deselect a column and re-add it
straight after.

To add a chunk of columns use the `start_col:end_col` syntax:

    kickstarter_sample %>%
      select(name:main_category, currency:pledged)

    ## # A tibble: 100 x 5
    ##    name                              main_category currency   goal pledged
    ##    <chr>                             <chr>         <chr>     <dbl>   <dbl>
    ##  1 Positive7 - Werde Teil der Beweg~ Art           EUR      2.00e4    1.00
    ##  2 The Buddz Break Out Album and Mu~ Music         USD      6.00e4  609   
    ##  3 Stupid Is As Stupid Does!         Music         CAD      1.50e2    4.00
    ##  4 CITFREE.COM                       Technology    AUD      5.00e3    0   
    ##  5 I won't stay silent               Music         USD      3.75e3   65.0 
    ##  6 "100% Ecological Lava Lamp - \"E~ Technology    EUR      2.50e4  744   
    ##  7 100s of Logos in 10 Days!         Design        USD      5.00e1  120   
    ##  8 Samurai Warrior the Anime Series  Film & Video  NOK      3.50e2    0   
    ##  9 Exploring Torontos Beer Scene As~ Food          CAD      1.00e2    5.00
    ## 10 Revolutionary Shorts: Join the C~ Theater       USD      6.50e2  721   
    ## # ... with 90 more rows

An alternative is to **deselect columns** by adding a minus sign in
front of the column name. You can also deselect chunks of columns. It's
even possible to deselect a whole chunk, and then re-add a column again
(as long as it is in the same select statement)

    #deselecting one column (ID), deselecting all columns from date_launched until the end, but re-adding some columns from that large chunk.
    kickstarter_sample %>% 
      select(-ID, -(date_launched:country), currency:pledged)

    ## # A tibble: 100 x 6
    ##    name                   main_category category   currency   goal pledged
    ##    <chr>                  <chr>         <chr>      <chr>     <dbl>   <dbl>
    ##  1 Positive7 - Werde Tei~ Art           Art        EUR      2.00e4    1.00
    ##  2 The Buddz Break Out A~ Music         Rock       USD      6.00e4  609   
    ##  3 Stupid Is As Stupid D~ Music         Punk       CAD      1.50e2    4.00
    ##  4 CITFREE.COM            Technology    Apps       AUD      5.00e3    0   
    ##  5 I won't stay silent    Music         Faith      USD      3.75e3   65.0 
    ##  6 "100% Ecological Lava~ Technology    Technology EUR      2.50e4  744   
    ##  7 100s of Logos in 10 D~ Design        Graphic D~ USD      5.00e1  120   
    ##  8 Samurai Warrior the A~ Film & Video  Animation  NOK      3.50e2    0   
    ##  9 Exploring Torontos Be~ Food          Drinks     CAD      1.00e2    5.00
    ## 10 Revolutionary Shorts:~ Theater       Theater    USD      6.50e2  721   
    ## # ... with 90 more rows

<br>

### **Selecting columns based on partial names**

If you have a lot of columns with a similar structure you can use
partial matching by adding `starts_with()`, `ends_with()` or
`contains()` in your select statement depending on how you want to match
columns.

I can for instance add all columns that contain the word 'category',
start with 'date' and end with the letter 'e'.()

    #selecting based on partial matches
    kickstarter_sample %>%
      select(contains("category"), starts_with("date"), ends_with("e")) 

    ## # A tibble: 100 x 6
    ##    main_category category  date_launched       date_deadline       name   
    ##    <chr>         <chr>     <dttm>              <dttm>              <chr>  
    ##  1 Art           Art       2016-08-16 23:33:53 2016-09-25 23:33:53 Positi~
    ##  2 Music         Rock      2013-04-02 02:25:07 2013-05-02 02:25:07 The Bu~
    ##  3 Music         Punk      2015-09-02 22:41:19 2015-11-01 22:41:19 Stupid~
    ##  4 Technology    Apps      2014-10-17 08:31:33 2014-12-16 08:31:33 CITFRE~
    ##  5 Music         Faith     2014-07-08 18:39:33 2014-08-13 00:16:00 I won'~
    ##  6 Technology    Technolo~ 2015-09-21 21:34:48 2015-11-05 21:34:48 "100% ~
    ##  7 Design        Graphic ~ 2012-01-28 23:17:24 2012-02-07 23:17:24 100s o~
    ##  8 Film & Video  Animation 2015-06-13 23:30:43 2015-07-13 23:30:43 Samura~
    ##  9 Food          Drinks    2015-03-10 23:39:48 2015-04-10 00:39:48 Explor~
    ## 10 Theater       Theater   2010-07-08 08:19:45 2010-08-04 05:59:00 Revolu~
    ## # ... with 90 more rows, and 1 more variable: state <chr>

<br>

### **Selecting columns based on regex**

The previous helper functions work with exact pattern matches. If you
have similar patterns that are not entirely the same you can use any
regular expression inside `matches()`.  
The below example code will add any columns where you have 'a.e' in the
title with the dot representing any other letter, but excludes the word
to be 'da.e', so the date columns will not be selected.

    #selecting based on regex
    kickstarter_sample %>%
      select(matches("[^d]a.e"))

    ## # A tibble: 100 x 4
    ##    name                                 main_category category     state  
    ##    <chr>                                <chr>         <chr>        <chr>  
    ##  1 Positive7 - Werde Teil der Bewegung! Art           Art          failed 
    ##  2 The Buddz Break Out Album and Music~ Music         Rock         cancel~
    ##  3 Stupid Is As Stupid Does!            Music         Punk         failed 
    ##  4 CITFREE.COM                          Technology    Apps         failed 
    ##  5 I won't stay silent                  Music         Faith        failed 
    ##  6 "100% Ecological Lava Lamp - \"Elav~ Technology    Technology   failed 
    ##  7 100s of Logos in 10 Days!            Design        Graphic Des~ succes~
    ##  8 Samurai Warrior the Anime Series     Film & Video  Animation    failed 
    ##  9 Exploring Torontos Beer Scene As A ~ Food          Drinks       failed 
    ## 10 Revolutionary Shorts: Join the Cause Theater       Theater      succes~
    ## # ... with 90 more rows

<br>

### **Selecting columns by their data type**

The `select_if` function allows you to pass functions which return
logical statements inside. For instance you can select all the string
columns by passing `select_if(is.character)`. Similarly, you can add
`is.numeric`, `is.integer`, `is.double`, `is.logical`, `is.factor`.

    #select all string columns
    kickstarter_sample %>%
      select_if(is.numeric)

    ## # A tibble: 100 x 3
    ##       goal pledged backers
    ##      <dbl>   <dbl>   <int>
    ##  1 20000      1.00       1
    ##  2 60000    609          5
    ##  3   150      4.00       2
    ##  4  5000      0          0
    ##  5  3750     65.0        5
    ##  6 25000    744         14
    ##  7    50.0  120          8
    ##  8   350      0          0
    ##  9   100      5.00       1
    ## 10   650    721          6
    ## # ... with 90 more rows

You can also select the negation but in this case you will need to add a
tilde to ensure that you still pass a function to `select_if`.

    kickstarter_sample %>%
      select_if(~!is.character(.))

    ## # A tibble: 100 x 5
    ##    date_launched       date_deadline          goal pledged backers
    ##    <dttm>              <dttm>                <dbl>   <dbl>   <int>
    ##  1 2016-08-16 23:33:53 2016-09-25 23:33:53 20000      1.00       1
    ##  2 2013-04-02 02:25:07 2013-05-02 02:25:07 60000    609          5
    ##  3 2015-09-02 22:41:19 2015-11-01 22:41:19   150      4.00       2
    ##  4 2014-10-17 08:31:33 2014-12-16 08:31:33  5000      0          0
    ##  5 2014-07-08 18:39:33 2014-08-13 00:16:00  3750     65.0        5
    ##  6 2015-09-21 21:34:48 2015-11-05 21:34:48 25000    744         14
    ##  7 2012-01-28 23:17:24 2012-02-07 23:17:24    50.0  120          8
    ##  8 2015-06-13 23:30:43 2015-07-13 23:30:43   350      0          0
    ##  9 2015-03-10 23:39:48 2015-04-10 00:39:48   100      5.00       1
    ## 10 2010-07-08 08:19:45 2010-08-04 05:59:00   650    721          6
    ## # ... with 90 more rows

<br>

### **Selecting columns by logical expressions**

In fact, `select_if` allows you to select based on any logical function,
not just based on data type. It is possible to select all columns with
an average above 500 for instance.  
To avoid errors you do have to also select numeric columns only, which
you can do either upfront for easier syntax, or in the same line.
Similarly `mean > 500` is not a function in itself, so you will need to
add a tilde upfront to turn the statement into a function.

    kickstarter_sample %>%
      select_if(is.numeric) %>%
      select_if(~mean(., na.rm=TRUE) > 500)

or shorter:

    kickstarter_sample %>%
      select_if(~is.numeric(.) & mean(., na.rm=TRUE)>500)

    ## # A tibble: 100 x 2
    ##       goal pledged
    ##      <dbl>   <dbl>
    ##  1 20000      1.00
    ##  2 60000    609   
    ##  3   150      4.00
    ##  4  5000      0   
    ##  5  3750     65.0 
    ##  6 25000    744   
    ##  7    50.0  120   
    ##  8   350      0   
    ##  9   100      5.00
    ## 10   650    721   
    ## # ... with 90 more rows

One of the useful functions for `select_if` is `n_distinct()`, which
counts the amount of distinct values that can be found in a column.  
To return the columns that have less than 20 distinct answers you pass
`~n_distinct(.) < 20` within the select\_if statement. Given that in
itself `n_distinct(.) < 20` is not a function, you will need to put a
tilde in front.

    kickstarter_sample %>%
      select_if(~n_distinct(.) < 20)

    ## # A tibble: 100 x 4
    ##    main_category currency state      country
    ##    <chr>         <chr>    <chr>      <chr>  
    ##  1 Art           EUR      failed     DE     
    ##  2 Music         USD      canceled   US     
    ##  3 Music         CAD      failed     CA     
    ##  4 Technology    AUD      failed     AU     
    ##  5 Music         USD      failed     US     
    ##  6 Technology    EUR      failed     ES     
    ##  7 Design        USD      successful US     
    ##  8 Film & Video  NOK      failed     NO     
    ##  9 Food          CAD      failed     CA     
    ## 10 Theater       USD      successful US     
    ## # ... with 90 more rows

<br>

------------------------------------------------------------------------

### **Adding new columns**

You can make new columns with the `mutate`function. This new column can
take many forms, you can do pretty much anything that you can do on
normal vectors, inside a mutate function.  
One of the many options is a calculation based on values in other
columns:

    #new column which looks at the difference between pledged money and the original goal
    kickstarter_sample %>%
      select(name, pledged, goal) %>%
      mutate(delta_pledged_goal = pledged - goal)

    ## # A tibble: 100 x 4
    ##    name                                   pledged   goal delta_pledged_go~
    ##    <chr>                                    <dbl>  <dbl>             <dbl>
    ##  1 Positive7 - Werde Teil der Bewegung!      1.00 2.00e4          -19999  
    ##  2 The Buddz Break Out Album and Music V~  609    6.00e4          -59391  
    ##  3 Stupid Is As Stupid Does!                 4.00 1.50e2          -  146  
    ##  4 CITFREE.COM                               0    5.00e3          - 5000  
    ##  5 I won't stay silent                      65.0  3.75e3          - 3685  
    ##  6 "100% Ecological Lava Lamp - \"Elava ~  744    2.50e4          -24256  
    ##  7 100s of Logos in 10 Days!               120    5.00e1              70.0
    ##  8 Samurai Warrior the Anime Series          0    3.50e2          -  350  
    ##  9 Exploring Torontos Beer Scene As A Br~    5.00 1.00e2          -   95.0
    ## 10 Revolutionary Shorts: Join the Cause    721    6.50e2              71.0
    ## # ... with 90 more rows

The new column can be made with functions such as average, median, max,
min, ...

    kickstarter_sample %>%
      select(pledged, goal) %>%
      mutate(pledge_delta_vs_average = pledged - mean(pledged),
             goal_delta_vs_max = goal - max(goal))

    ## # A tibble: 100 x 4
    ##    pledged    goal pledge_delta_vs_average goal_delta_vs_max
    ##      <dbl>   <dbl>                   <dbl>             <dbl>
    ##  1    1.00 20000                    -13025            -80000
    ##  2  609    60000                    -12417            -40000
    ##  3    4.00   150                    -13022            -99850
    ##  4    0     5000                    -13026            -95000
    ##  5   65.0   3750                    -12961            -96250
    ##  6  744    25000                    -12282            -75000
    ##  7  120       50.0                  -12906            -99950
    ##  8    0      350                    -13026            -99650
    ##  9    5.00   100                    -13021            -99900
    ## 10  721      650                    -12305            -99350
    ## # ... with 90 more rows

You can also mutate string columns with stringr's `str_extract()`
function in combation with any character or regex patterns.

    #adding new column which has only the first word of the project name
    kickstarter_sample %>%
      mutate(name_first_word = str_extract(name, pattern = "^\\w+")) %>%
      select(name, name_first_word)

    ## # A tibble: 100 x 2
    ##    name                                                    name_first_word
    ##    <chr>                                                   <chr>          
    ##  1 Positive7 - Werde Teil der Bewegung!                    Positive7      
    ##  2 The Buddz Break Out Album and Music Video (Canceled)    The            
    ##  3 Stupid Is As Stupid Does!                               Stupid         
    ##  4 CITFREE.COM                                             CITFREE        
    ##  5 I won't stay silent                                     I              
    ##  6 "100% Ecological Lava Lamp - \"Elava Lamp\""            100            
    ##  7 100s of Logos in 10 Days!                               100s           
    ##  8 Samurai Warrior the Anime Series                        Samurai        
    ##  9 Exploring Torontos Beer Scene As A Broke College Stude~ Exploring      
    ## 10 Revolutionary Shorts: Join the Cause                    Revolutionary  
    ## # ... with 90 more rows

<br>

### **Merging and unmerging columns**

You can paste two columns together via tidyr's `unite()` function. You
specify the new column name, and then the columns to be united, and
lastly what seperator you want to use.

    #merging currency and goal columns
    (ks_merge <- kickstarter_sample %>%
      unite(goal_currency, currency, goal, sep=" ") %>%
      select(name, goal_currency))

    ## # A tibble: 100 x 2
    ##    name                                                     goal_currency
    ##  * <chr>                                                    <chr>        
    ##  1 Positive7 - Werde Teil der Bewegung!                     EUR 20000    
    ##  2 The Buddz Break Out Album and Music Video (Canceled)     USD 60000    
    ##  3 Stupid Is As Stupid Does!                                CAD 150      
    ##  4 CITFREE.COM                                              AUD 5000     
    ##  5 I won't stay silent                                      USD 3750     
    ##  6 "100% Ecological Lava Lamp - \"Elava Lamp\""             EUR 25000    
    ##  7 100s of Logos in 10 Days!                                USD 50       
    ##  8 Samurai Warrior the Anime Series                         NOK 350      
    ##  9 Exploring Torontos Beer Scene As A Broke College Student CAD 100      
    ## 10 Revolutionary Shorts: Join the Cause                     USD 650      
    ## # ... with 90 more rows

You can unmerge any columns by using tidyr's `separate())` function. To
do this, you have to specify the column to be splitted, followed by the
new column names, and which seperator it has to look for.

    #splitting the previous made column
    ks_merge %>%
      separate(goal_currency, into = c("goal", "currency"), sep=" ")

    ## # A tibble: 100 x 3
    ##    name                                                     goal  currency
    ##  * <chr>                                                    <chr> <chr>   
    ##  1 Positive7 - Werde Teil der Bewegung!                     EUR   20000   
    ##  2 The Buddz Break Out Album and Music Video (Canceled)     USD   60000   
    ##  3 Stupid Is As Stupid Does!                                CAD   150     
    ##  4 CITFREE.COM                                              AUD   5000    
    ##  5 I won't stay silent                                      USD   3750    
    ##  6 "100% Ecological Lava Lamp - \"Elava Lamp\""             EUR   25000   
    ##  7 100s of Logos in 10 Days!                                USD   50      
    ##  8 Samurai Warrior the Anime Series                         NOK   350     
    ##  9 Exploring Torontos Beer Scene As A Broke College Student CAD   100     
    ## 10 Revolutionary Shorts: Join the Cause                     USD   650     
    ## # ... with 90 more rows

<br>

### **Adding columns from other tables**

If I want to add information from another type, you can use the joining
functions from dplyr. The kickstarter tables only contains a
country\_code. If i want to add a full country name, or I want to do
analysis on specific country data, I can add data from another table.  
Take for instance this country\_info data:

    country_info <- read_csv("data/country_codes.csv")

    #splitting the ISO_codes column which shows "US / USA" into two different columns
    country_info <- country_info %>%
      separate(ISO_CODES, into = c("code_alpha2", "code_alpha3"), sep = " / ") %>%
      glimpse

    ## Observations: 240
    ## Variables: 7
    ## $ COUNTRY      <chr> "Afghanistan", "Albania", "Algeria", "American Sa...
    ## $ COUNTRY_CODE <chr> "93", "355", "213", "1-684", "376", "244", "1-264...
    ## $ code_alpha2  <chr> "AF", "AL", "DZ", "AS", "AD", "AO", "AI", "AQ", "...
    ## $ code_alpha3  <chr> "AFG", "ALB", "DZA", "ASM", "AND", "AGO", "AIA", ...
    ## $ POPULATION   <dbl> 29121286, 2986952, 34586184, 57881, 84000, 130681...
    ## $ AREA_KM2     <dbl> 647500, 28748, 2381740, 199, 468, 1246700, 102, 1...
    ## $ GDP_USD      <chr> "20.65 Billion", "12.8 Billion", "215.7 Billion",...

If I want to merge this info in my kickstarter data, I can do a
left\_join based on the country\_code column:

    #joining column data
    kickstarter %>%
      select(project = name, state, country) %>%
      left_join(country_info, by = c("country" = "code_alpha2")) %>%
      glimpse

    ## Observations: 378,661
    ## Variables: 9
    ## $ project      <chr> "The Songs of Adelaide & Abullah", "Greeting From...
    ## $ state        <chr> "failed", "failed", "failed", "failed", "canceled...
    ## $ country      <chr> "GB", "US", "US", "US", "US", "US", "US", "US", "...
    ## $ COUNTRY      <chr> "United Kingdom", "United States", "United States...
    ## $ COUNTRY_CODE <chr> "44", "1", "1", "1", "1", "1", "1", "1", "1", "1"...
    ## $ code_alpha3  <chr> "GBR", "USA", "USA", "USA", "USA", "USA", "USA", ...
    ## $ POPULATION   <dbl> 62348447, 310232863, 310232863, 310232863, 310232...
    ## $ AREA_KM2     <dbl> 244820, 9629091, 9629091, 9629091, 9629091, 96290...
    ## $ GDP_USD      <chr> "2.49 Trillion", "16.72 Trillion", "16.72 Trillio...

<br>

### **Miscellaneous**

Some dataframes have rownames that are not actually a column in itself,
like the mtcars dataset:

    mtcars %>%
      head

    ##                    mpg cyl disp  hp drat    wt  qsec vs am gear carb
    ## Mazda RX4         21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
    ## Mazda RX4 Wag     21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
    ## Datsun 710        22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
    ## Hornet 4 Drive    21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
    ## Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
    ## Valiant           18.1   6  225 105 2.76 3.460 20.22  1  0    3    1

If you want this column to be an actual column, you can use the
`rownames_to_column()` function, and specify a new column name.

    mtcars %>%
      rownames_to_column("car_model") %>%
      head

    ##           car_model  mpg cyl disp  hp drat    wt  qsec vs am gear carb
    ## 1         Mazda RX4 21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
    ## 2     Mazda RX4 Wag 21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
    ## 3        Datsun 710 22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
    ## 4    Hornet 4 Drive 21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
    ## 5 Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
    ## 6           Valiant 18.1   6  225 105 2.76 3.460 20.22  1  0    3    1

<br><br>

------------------------------------------------------------------------

Rows
====

### **Arranging rows**

In many cases you do not want to show the dataset as it is, but want to
arrange based on a certain column. The function arrange allows you to
order a column alphabetically (if the column is a character column), or
based on small-large with the `arrange()` function.  
If you want descending order, add `arrange(desc())` to your pipeline.
The below code shows the 5 projects with the highest amount of backers.

    kickstarter %>%
      select(main_category, category, project = name, backers) %>%
      arrange(desc(backers)) %>%
      top_n(5)

    ## Selecting by backers

    ## # A tibble: 5 x 4
    ##   main_category category       project                             backers
    ##   <chr>         <chr>          <chr>                                 <int>
    ## 1 Games         Tabletop Games Exploding Kittens                    219382
    ## 2 Design        Product Design Fidget Cube: A Vinyl Desk Toy        154926
    ## 3 Technology    Web            Bring Reading Rainbow Back for Eve~  105857
    ## 4 Film & Video  Narrative Film The Veronica Mars Movie Project       91585
    ## 5 Games         Video Games    Double Fine Adventure                 87142

<br>

### **Filtering based on numerical columns**

To select certain rows, you use the `filter()` function. You can pass a
logical statement to filter:  
To filter all projects where the goal was higher than 1000:

    kickstarter %>%
      filter(goal < 1000) %>%
      select(name, goal)

    ## # A tibble: 46,958 x 2
    ##    name                                                  goal
    ##    <chr>                                                <dbl>
    ##  1 Mike Corey's Darkness & Light Album                    250
    ##  2 Mountain brew: A quest for alcohol sustainability      500
    ##  3 The Book Zoo - A Mini-Comic                            175
    ##  4 Rebel Army Origins: The Heroic Story Of Major Gripes   100
    ##  5 "\"JurassicJurassix\" by The Guilt"                    850
    ##  6 VOTE (anyone but) TRUMP Candle                         500
    ##  7 Spiral Electric Skylab Recording                       500
    ##  8 The Locals Only Shirt                                  500
    ##  9 Just Another Reality Show: Season 3                    500
    ## 10 Backroads EP Processing Costs                          200
    ## # ... with 46,948 more rows

For numeric columns you can also pass arange, either by using two
logical statments:`filter(goal <= 1000, goal >= 500)` or by using the
`between` option:

    kickstarter %>%
      filter(between(goal, 500, 1000)) %>%
      #Alternative: filter(goal <= 1000, goal >= 500)
      select(name, goal)

    ## # A tibble: 42,583 x 2
    ##    name                                                          goal
    ##    <chr>                                                        <dbl>
    ##  1 The Songs of Adelaide & Abullah                               1000
    ##  2 Support Solar Roasted Coffee & Green Energy!  SolarCoffee.co  1000
    ##  3 Mountain brew: A quest for alcohol sustainability              500
    ##  4 Ledr workbook: one tough journal!                             1000
    ##  5 "\"JurassicJurassix\" by The Guilt"                            850
    ##  6 VOTE (anyone but) TRUMP Candle                                 500
    ##  7 Spiral Electric Skylab Recording                               500
    ##  8 The Locals Only Shirt                                          500
    ##  9 Just Another Reality Show: Season 3                            500
    ## 10 Disaster Area: A Podcast                                      1000
    ## # ... with 42,573 more rows

<br>

### **Filtering based on string columns**

You can also filter character columns based on a column value. The below
code keeps all projects that were successful. The final `count(state)`
collapses all retained rows and counts what is left in the output table
by state.

    kickstarter %>%
      filter(state == "successful") %>%
      count(state)

    ## # A tibble: 1 x 2
    ##   state           n
    ##   <chr>       <int>
    ## 1 successful 133956

If you want to filter out a few character values, you can use the `%in%`
operator:

    kickstarter %>%
      filter(state %in% c("successful", "failed")) %>%
      count(state) %>%
      arrange(desc(n))

    ## # A tibble: 2 x 2
    ##   state           n
    ##   <chr>       <int>
    ## 1 failed     197719
    ## 2 successful 133956

You can use any other logical statement. If you would use
`filter(state > n)` the output table would only show any values of state
that are alphabetically after the letter n.  
Or you can use the `!=` operator to deselect any values:

    kickstarter %>%
      filter(state != "undefined") %>%
      count(state) %>%
      arrange(desc(n))

    ## # A tibble: 5 x 2
    ##   state           n
    ##   <chr>       <int>
    ## 1 failed     197719
    ## 2 successful 133956
    ## 3 canceled    38779
    ## 4 live         2799
    ## 5 suspended    1846

<br>

### **Regex based filtering**

The above string operators only work on full matches. If you want to
filter based on partial matches, you can use the regex experssions
inside a filter function. You can use base R's `grepl` function, or
stringr's `str_detect()`.

    kickstarter %>%
      filter(str_detect(name, pattern=" cats? ")) %>%
      #alternative with grepl: filter(grepl(pattern=" cats? ", name)) %>%
      select(name, state)

    ## # A tibble: 91 x 2
    ##    name                                                        state     
    ##    <chr>                                                       <chr>     
    ##  1 kittybiome: kitty microbiomes for cat health and biology    successful
    ##  2 CAT ATTACK, the card game - 'cauze cats top the foodchain!  failed    
    ##  3 Cats in a Cradle by a bunch of cat lovers                   failed    
    ##  4 Clever, funny and very cute. Purrfect gifts for cat lovers. canceled  
    ##  5 I knit cuddly blankets for abandoned cats in shelters :D    successful
    ##  6 The Kitty Funnel - Your cat will never miss a visit!        failed    
    ##  7 Aromatherapy cat beds                                       failed    
    ##  8 I want to learn how to draw a cat (Canceled)                canceled  
    ##  9 First cat cafe in Virginia!                                 live      
    ## 10 New Chainmail gamer Dice bags & cat collars and bracelets   successful
    ## # ... with 81 more rows

In many cases you will need to take into account that R is case
sensitive. By just checking for 'cats', we missed many projects. You can
add a `tolower()` call inside `str_detect()` to avoid these issues.

    kickstarter %>%
      filter(str_detect(tolower(name), pattern = " cats? ")) %>%
      #grepl alternative: filter(grepl(pattern=" cats? ", name, ignore.case=TRUE)) %>%
      select(name, state)

    ## # A tibble: 642 x 2
    ##    name                                                         state     
    ##    <chr>                                                        <chr>     
    ##  1 'FLIP' the Bird & Cat Game (Canceled)                        canceled  
    ##  2 Medieval & Renaissance Luxury Cat and Dog collars            successful
    ##  3 The QuickSnap Replaceable Cat Scratcher - Feline Innovations successful
    ##  4 The Cheshire Cat Cafe Llandudno #Wales1stcatcafe             failed    
    ##  5 Catzenpup Automatic Wet Food Feeder For Cats & Dogs          failed    
    ##  6 kittybiome: kitty microbiomes for cat health and biology     successful
    ##  7 The Cartoon Cat Limited Edition Silk Screened Print          failed    
    ##  8 CAT ATTACK, the card game - 'cauze cats top the foodchain!   failed    
    ##  9 The Adventures Of BooBoo The Cat - A Bedtime Story           failed    
    ## 10 The Old Woman and the Shaggy Old Cat - Christmas Book        failed    
    ## # ... with 632 more rows

<br>

### **Filtering based on multiple conditions**

You can add multiple conditions inside one filter statement. By default
adding multiple conditions with a comma, means that both statments have
to be true for the row to be retained

    #AND clause in filter
    kickstarter %>%
      filter(country == "BE", goal > 200000) %>%
      print(5)

    ## # A tibble: 17 x 12
    ##    ID      name                main_category category  date_launched      
    ##    <chr>   <chr>               <chr>         <chr>     <dttm>             
    ##  1 100583~ The Last Dictator   Film & Video  Film & V~ 2015-09-14 17:36:42
    ##  2 120288~ BISE: Meet instant~ Technology    Apps      2015-12-21 17:14:48
    ##  3 140369~ BELGIAN GOLD (Canc~ Food          Restaura~ 2015-11-02 19:50:18
    ##  4 184112~ Belgian Gold        Food          Restaura~ 2015-11-09 13:06:51
    ##  5 209411~ EcoDraft: High end~ Technology    Makerspa~ 2016-10-13 12:28:46
    ##  6 237278~ Flyboard Air®       Technology    Technolo~ 2017-07-16 14:56:18
    ##  7 256335~ Bringing Belgian F~ Food          Restaura~ 2015-12-11 11:19:57
    ##  8 417752~ BISE: Meet instant~ Technology    Apps      2015-12-24 12:00:31
    ##  9 524396~ Soul Society | Spi~ Design        Design    2016-02-06 02:42:44
    ## 10 582018~ Go4ourika 2018      Food          Farms     2017-10-30 20:45:23
    ## 11 721826~ Blue Angelo : The ~ Games         Video Ga~ 2016-03-08 15:00:02
    ## 12 761743~ Slidenjoy - Double~ Technology    Technolo~ 2015-07-07 21:04:39
    ## 13 787614~ The Cortex Game     Games         Video Ga~ 2015-07-15 09:23:06
    ## 14 788050~ Belgian-French Bis~ Food          Restaura~ 2017-10-03 22:10:06
    ## 15 807822~ Go4Ourika           Food          Farms     2016-09-18 22:12:28
    ## 16 920155~ Eventurapp          Technology    Apps      2016-07-28 18:45:45
    ## 17 986066~ HalalAdvisor Ltd    Technology    Apps      2017-09-18 12:54:53
    ## # ... with 7 more variables: date_deadline <dttm>, currency <chr>,
    ## #   goal <dbl>, pledged <dbl>, state <chr>, backers <int>, country <chr>

If you want a row to be retained in one OR the other condition, you have
to add the `|` operator.  
You can combine multiple and, or and not conditions:

    #AND and OR clause
    kickstarter %>%
      filter(country == "BE", (state == "successful" | goal > 1000000))

    ## # A tibble: 153 x 12
    ##    ID      name                main_category category  date_launched      
    ##    <chr>   <chr>               <chr>         <chr>     <dttm>             
    ##  1 100415~ Chimera Station - ~ Games         Tabletop~ 2017-03-31 11:57:59
    ##  2 100870~ Interactions - the~ Photography   Photoboo~ 2016-04-22 15:19:17
    ##  3 101904~ Handcrafted leathe~ Fashion       Accessor~ 2015-12-11 10:52:29
    ##  4 102487~ The revolutionary ~ Fashion       Apparel   2016-07-22 06:31:14
    ##  5 106159~ Partage ta Vache #~ Food          Farms     2015-11-28 11:39:45
    ##  6 106733~ Het Oog des Meeste~ Games         Tabletop~ 2017-10-10 16:15:35
    ##  7 107578~ A History of Disne~ Publishing    Nonficti~ 2016-03-27 01:47:16
    ##  8 108302~ "From Architecture~ Design        Design    2017-07-18 06:25:34
    ##  9 109256~ BOOK: Fools With D~ Photography   Photoboo~ 2017-06-06 09:58:42
    ## 10 109585~ BOHO Players - Per~ Music         Classica~ 2015-07-27 17:57:01
    ## # ... with 143 more rows, and 7 more variables: date_deadline <dttm>,
    ## #   currency <chr>, goal <dbl>, pledged <dbl>, state <chr>, backers <int>,
    ## #   country <chr>

<br>

### **Filtering across columns**

If you are filtering across columns for the same values, `filter_all()`
can save you some typing space.  
Imagine we want to retain any projects that have the word "fashion"
inside a category or inside its project name. We can do this by adding 3
conditions:

    kickstarter %>%
      select(name, contains("category")) %>%
      filter(str_detect(tolower(name), pattern = "fashion") |
             str_detect(tolower(category), pattern = "fashion") |
             str_detect(tolower(main_category), pattern = "fashion"))

This is a lot of typing and copy pasting though. An alternative is to
use `filter_all()`:

    kickstarter %>%
      select(name, contains("category")) %>%
      filter_all(any_vars(str_detect(tolower(.), pattern = "fashion"))) %>%
      filter(main_category != "Fashion")

    ## # A tibble: 408 x 3
    ##    name                                         main_category category    
    ##    <chr>                                        <chr>         <chr>       
    ##  1 FashionRider Show & Tell - Video Documentary Film & Video  Film & Video
    ##  2 Collabrative Fashion Film                    Film & Video  Experimental
    ##  3 Clotheshorse - Fashion.                      Crafts        Crafts      
    ##  4 God, Fashion, Baking, and DIY Youtube Chann~ Film & Video  Webseries   
    ##  5 Arcane Creations: A Rock Fashion Show 4 Sta~ Art           Mixed Media 
    ##  6 que Bottle: The Fashionable & Collapsible T~ Design        Product Des~
    ##  7 Introducing Free Press Fashions & The Tea S~ Journalism    Journalism  
    ##  8 Smart Wallet: Locator & Charger a Fashionab~ Technology    Hardware    
    ##  9 INK & FASHION                                Publishing    Art Books   
    ## 10 Journal of a Single Girl through Italy: Art~ Journalism    Journalism  
    ## # ... with 398 more rows

The `filter_all()` function can also be used with numeric input. To
retain all rows where both goal and columns are below 5000 you can use
`filter_all(all_vars())`:

    kickstarter %>%
      select(goal, pledged) %>%
      filter_all(all_vars(.<5000))

    ## # A tibble: 150,829 x 2
    ##     goal pledged
    ##    <dbl>   <dbl>
    ##  1  1000    0   
    ##  2  1000 1205   
    ##  3  2500    0   
    ##  4  2500  664   
    ##  5  1500  395   
    ##  6  3000  789   
    ##  7   250  250   
    ##  8  2500    1.00
    ##  9  3500  650   
    ## 10   500   48.0 
    ## # ... with 150,819 more rows

The OR-version of this statement is `filter_all(any_vars())`.  
To retain any rows where either column is below 5000.

    kickstarter %>%
      select(goal, pledged) %>%
      filter_all(any_vars(.<5000))

    ## # A tibble: 301,301 x 2
    ##      goal pledged
    ##     <dbl>   <dbl>
    ##  1   1000    0   
    ##  2  30000 2421   
    ##  3  45000  220   
    ##  4   5000    1.00
    ##  5  19500 1283   
    ##  6   1000 1205   
    ##  7  25000  453   
    ##  8   2500    0   
    ##  9   5000    0   
    ## 10 200000    0   
    ## # ... with 301,291 more rows

The above solution does not always work well if you have both character
and numeric columns. In these cases it might be better to use
`filter_if`:

    kickstarter %>%
      select(name, goal, pledged) %>%
      filter_if(is.numeric, all_vars(.>1000000)) %>%
      print(5)

    ## # A tibble: 18 x 3
    ##    name                                                       goal pledged
    ##    <chr>                                                     <dbl>   <dbl>
    ##  1 THE P-51 AUTOMATIC WATCH by REC - Recycling Horsepower!  1.40e6 3193364
    ##  2 Bring Back MYSTERY SCIENCE THEATER 3000                  2.00e6 5764229
    ##  3 PixelJunk™ Monsters Duo Mobile Game                      1.20e7 1729241
    ##  4 The Newest Hottest Spike Lee Joint                       1.25e6 1418910
    ##  5 Ghost S1 MkII                                            2.00e6 2588997
    ##  6 Camelot Unchained                                        2.00e6 2232933
    ##  7 Obduction                                                1.10e6 1321306
    ##  8 The Veronica Mars Movie Project                          2.00e6 5702153
    ##  9 WISH I WAS HERE                                          2.00e6 3105473
    ## 10 DRESS UP BOX — Make-Believe Clothing for Girls           1.10e6 1121500
    ## 11 The 901 Collection - Made from salvaged Porsche 911’s    1.40e6 4075739
    ## 12 Folkegaven: Underholdningsorkestret (Canceled)           3.00e6 1058547
    ## 13 MARUHI Cup & Saucer                                      3.00e6 1748630
    ## 14 Project Eternity                                         1.10e6 3986929
    ## 15 Blue Mountain State: The Movie                           1.50e6 1911827
    ## 16 The Bards Tale IV                                        1.25e6 1519681
    ## 17 Elite: Dangerous                                         1.25e6 1578316
    ## 18 Shenmue 3                                                2.00e6 6333296

<br><br>

------------------------------------------------------------------------

Miscellaneous
=============

A few final tips:

### **Geting data out of a pipe as a vector**

If you want to get info in a vector, you can use the `pull()` function
at the end. Imagine you want the mean value of a specific subgroup. If
you just save the output it will be tibble of 1x1 rather than a vector.:

    kickstarter %>%
      filter(state == "successful", country=="BE") %>%
      summarise(mean(pledged))

    ## # A tibble: 1 x 1
    ##   `mean(pledged)`
    ##             <dbl>
    ## 1           21973

By adding a `pull()` statement you will get a vector as outpt:

    kickstarter %>%
      filter(state == "successful", country=="BE") %>%
      summarise(mean(pledged)) %>%
      pull()

    ## [1] 21972.74

You can also use pull on a longer vector:

    #what different categories are there? 
    kickstarter %>%
      count(main_category) %>%
      pull(main_category)

    ##  [1] "Art"          "Comics"       "Crafts"       "Dance"       
    ##  [5] "Design"       "Fashion"      "Film & Video" "Food"        
    ##  [9] "Games"        "Journalism"   "Music"        "Photography" 
    ## [13] "Publishing"   "Technology"   "Theater"

<br>

### **Printing prettier tables in Rmd**

Inside an Rmardown document you can print prettier tables pretty easily
by adding a `knitr::kable()` statement.

    kickstarter %>%
      group_by(main_category) %>%
      summarise(number_of_projects = n(),
                perc_successful = mean(state == "successful"),
                avg_backers = mean(backers),
                avg_pledged = mean(pledged)) %>%
      arrange(desc(perc_successful)) %>%
      knitr::kable()

<table>
<thead>
<tr class="header">
<th align="left">main_category</th>
<th align="right">number_of_projects</th>
<th align="right">perc_successful</th>
<th align="right">avg_backers</th>
<th align="right">avg_pledged</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">Dance</td>
<td align="right">3768</td>
<td align="right">0.6204883</td>
<td align="right">42.80122</td>
<td align="right">3690.799</td>
</tr>
<tr class="even">
<td align="left">Theater</td>
<td align="right">10913</td>
<td align="right">0.5987355</td>
<td align="right">47.05727</td>
<td align="right">4097.225</td>
</tr>
<tr class="odd">
<td align="left">Comics</td>
<td align="right">10819</td>
<td align="right">0.5399760</td>
<td align="right">134.77124</td>
<td align="right">6899.311</td>
</tr>
<tr class="even">
<td align="left">Music</td>
<td align="right">51918</td>
<td align="right">0.4660619</td>
<td align="right">52.16832</td>
<td align="right">3992.736</td>
</tr>
<tr class="odd">
<td align="left">Art</td>
<td align="right">28153</td>
<td align="right">0.4088374</td>
<td align="right">42.20509</td>
<td align="right">3606.970</td>
</tr>
<tr class="even">
<td align="left">Film &amp; Video</td>
<td align="right">63585</td>
<td align="right">0.3715184</td>
<td align="right">66.01521</td>
<td align="right">6362.734</td>
</tr>
<tr class="odd">
<td align="left">Games</td>
<td align="right">35231</td>
<td align="right">0.3553121</td>
<td align="right">321.78561</td>
<td align="right">21865.173</td>
</tr>
<tr class="even">
<td align="left">Design</td>
<td align="right">30070</td>
<td align="right">0.3508480</td>
<td align="right">241.29963</td>
<td align="right">27119.751</td>
</tr>
<tr class="odd">
<td align="left">Publishing</td>
<td align="right">39874</td>
<td align="right">0.3084717</td>
<td align="right">55.96602</td>
<td align="right">3638.716</td>
</tr>
<tr class="even">
<td align="left">Photography</td>
<td align="right">10779</td>
<td align="right">0.3066147</td>
<td align="right">39.71407</td>
<td align="right">3664.647</td>
</tr>
<tr class="odd">
<td align="left">Food</td>
<td align="right">24602</td>
<td align="right">0.2473376</td>
<td align="right">54.17247</td>
<td align="right">5340.163</td>
</tr>
<tr class="even">
<td align="left">Fashion</td>
<td align="right">22816</td>
<td align="right">0.2451350</td>
<td align="right">61.44780</td>
<td align="right">6549.032</td>
</tr>
<tr class="odd">
<td align="left">Crafts</td>
<td align="right">8809</td>
<td align="right">0.2400954</td>
<td align="right">27.28369</td>
<td align="right">2016.154</td>
</tr>
<tr class="even">
<td align="left">Journalism</td>
<td align="right">4755</td>
<td align="right">0.2128286</td>
<td align="right">38.29464</td>
<td align="right">3218.085</td>
</tr>
<tr class="odd">
<td align="left">Technology</td>
<td align="right">32569</td>
<td align="right">0.1975498</td>
<td align="right">164.46661</td>
<td align="right">22586.165</td>
</tr>
</tbody>
</table>

You can also provide more info on how the table has to look:  
For more options look into the `kable()` and `kableExtra()`
documentation.

    kickstarter %>%
      group_by(main_category) %>%
      summarise(number_of_projects = n(),
                perc_successful = mean(state == "successful")*100,
                avg_backers = mean(backers),
                avg_pledged = mean(pledged)) %>%
      mutate(perc_successful = paste(round(perc_successful), "%")) %>%
      arrange(desc(perc_successful)) %>%
      knitr::kable(digits = 0,
                   caption = "Summary of the data by main category", 
                   col.names = c("Main Category", "Number of Projects", 
                                   "Percent Successful", "Average amount of backers", 
                                   "Average amount of money pledged"))

<table>
<caption>Summary of the data by main category</caption>
<thead>
<tr class="header">
<th align="left">Main Category</th>
<th align="right">Number of Projects</th>
<th align="left">Percent Successful</th>
<th align="right">Average amount of backers</th>
<th align="right">Average amount of money pledged</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">Dance</td>
<td align="right">3768</td>
<td align="left">62 %</td>
<td align="right">43</td>
<td align="right">3691</td>
</tr>
<tr class="even">
<td align="left">Theater</td>
<td align="right">10913</td>
<td align="left">60 %</td>
<td align="right">47</td>
<td align="right">4097</td>
</tr>
<tr class="odd">
<td align="left">Comics</td>
<td align="right">10819</td>
<td align="left">54 %</td>
<td align="right">135</td>
<td align="right">6899</td>
</tr>
<tr class="even">
<td align="left">Music</td>
<td align="right">51918</td>
<td align="left">47 %</td>
<td align="right">52</td>
<td align="right">3993</td>
</tr>
<tr class="odd">
<td align="left">Art</td>
<td align="right">28153</td>
<td align="left">41 %</td>
<td align="right">42</td>
<td align="right">3607</td>
</tr>
<tr class="even">
<td align="left">Film &amp; Video</td>
<td align="right">63585</td>
<td align="left">37 %</td>
<td align="right">66</td>
<td align="right">6363</td>
</tr>
<tr class="odd">
<td align="left">Games</td>
<td align="right">35231</td>
<td align="left">36 %</td>
<td align="right">322</td>
<td align="right">21865</td>
</tr>
<tr class="even">
<td align="left">Design</td>
<td align="right">30070</td>
<td align="left">35 %</td>
<td align="right">241</td>
<td align="right">27120</td>
</tr>
<tr class="odd">
<td align="left">Photography</td>
<td align="right">10779</td>
<td align="left">31 %</td>
<td align="right">40</td>
<td align="right">3665</td>
</tr>
<tr class="even">
<td align="left">Publishing</td>
<td align="right">39874</td>
<td align="left">31 %</td>
<td align="right">56</td>
<td align="right">3639</td>
</tr>
<tr class="odd">
<td align="left">Fashion</td>
<td align="right">22816</td>
<td align="left">25 %</td>
<td align="right">61</td>
<td align="right">6549</td>
</tr>
<tr class="even">
<td align="left">Food</td>
<td align="right">24602</td>
<td align="left">25 %</td>
<td align="right">54</td>
<td align="right">5340</td>
</tr>
<tr class="odd">
<td align="left">Crafts</td>
<td align="right">8809</td>
<td align="left">24 %</td>
<td align="right">27</td>
<td align="right">2016</td>
</tr>
<tr class="even">
<td align="left">Journalism</td>
<td align="right">4755</td>
<td align="left">21 %</td>
<td align="right">38</td>
<td align="right">3218</td>
</tr>
<tr class="odd">
<td align="left">Technology</td>
<td align="right">32569</td>
<td align="left">20 %</td>
<td align="right">164</td>
<td align="right">22586</td>
</tr>
</tbody>
</table>
