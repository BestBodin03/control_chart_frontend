# 📈 Manufactoring Quality Control (Front-End)
Please read the [<ins>Back-End repository</ins>](https://github.com/BestBodin03/control_chart_backend) before reading this.

      In this repository we will talk about techniques and
      tools that are used in Front-End development.

----

### Page Sample
> Because of the __disclosure policy__, I can't show the real page in this, so I use a mock page that is designed like it.

##### It have 3 main pages
__1. Setting__
<br>
This page is for managing resources to show on the __Home__ page and for importing new data to the system.
<br>
<br>
__Profile Setting Tab__
<br>
<br>
<img src="images\setting\setting1.jpg" alt="architecture" width="640"> 

__<p>Data Tab</p>__
<img src="images\setting\setting2.jpg" alt="architecture" width="640"> 
__2. Search__
<br>
This page is used when you want to see something specific and show it immediately, and it does not affect the Home page.
<br>
<br>
<img src="images\search\search_github1.jpg" alt="architecture" width="640"> 
__When click info icon__
<br>
When points are very close, use this to see details more clearly.
<br>
<img src="images\search\search_github2.jpg" alt="architecture" width="640"> 
<br>
__3. Home__
<br>
It replaces paper dashboards posted on the bulletin board with a TV-friendly, timed carousel.
<br>
<br>
<img src="images\home\home_github1.jpg" alt="architecture" width="640"> 
<img src="images\home\home_github2.jpg" alt="architecture" width="640"> 
### Tech Stack
![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)

### Packages
##### - bloc
>Use for state management, and I write it in __Single State Class__ style.

##### - dio
>I adjust GET, UPDATE, and PATCH, etc., to standardize the body of response from the backend.

##### - shared_preferences
>I use this to store the profile that sets resources to show in __Home__.

##### - fl_chart
>Use it to create the __control chart__, and I plot it in __Irregular time-series__ form.
