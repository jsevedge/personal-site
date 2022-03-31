---
title: "Introduction to Jupyter Notebooks"
author: "James Sevedge"
meta_desc: ""
date: 2022-03-30
show_reading_time: true
tags: []
---

It has been on my bucket list for awhile now to expore [Jupyter Notebooks](https://jupyter.org) as a solution for data analysis and computational story telling needs. I finally took the time to sit down and understand the tooling and authoring experience and figured I would document the process and share it.

### Installation process

My local development environment is a MacBook Pro running Catalina. I started out by installing and launching the Jupyter Notebook server using [Anaconda](https://www.anaconda.com/products/distribution) which was uber simple.  I did want to be able to reproduce the installation and execution steps in a containerized pipeline so I ended up just doing a python package install after a bit of research on core python packages necessary.

```bash
$ pip install notebook pandas matplotlib
```

**Note:** For a pipeline of course I would pin the package versions in a `requirements.txt` file to ensure I had reproducible builds.

### Trying it out

Now that I have the Jupyter CLI installed I can start the Jupyter notebook server which opens a browser to localhost:8088 with a simple file explorer and a few options including creating a new notebook.

```bash
$ jupyter notebook
[I NotebookApp] Serving notebooks from local directory: /Users/a_user/Documents
[I NotebookApp] Jupyter Notebook 6.4.10 is running at:
[I NotebookApp] http://localhost:8888/?token=a_token
[I NotebookApp]  or http://127.0.0.1:8888/?token=a_token
[I NotebookApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
```

I selected the option to create a notebook and found myself staring at an empty Jupyter Notebook.

![Jupyter Notebook New](/jupyter-notebook-new.png)

### Finding some data

To create a useful Jupyter notebook I needed a simple data set so I downloaded a CSV file containing daily trading data on the S&P 500 for the 20 years starting from 2000.  Here is what a sample of that data looks like.

```bash
$ wc -l data.csv
    5000 data.csv
$ tail data.csv
"Jan 14, 2000","1,465.20","1,449.70","1,473.00","1,449.70","-","1.07%"
"Jan 13, 2000","1,449.70","1,432.20","1,454.60","1,432.20","-","1.22%"
"Jan 12, 2000","1,432.20","1,439.10","1,445.30","1,427.30","-","-0.44%"
"Jan 11, 2000","1,438.60","1,457.60","1,458.80","1,434.40","-","-1.30%"
"Jan 10, 2000","1,457.60","1,441.50","1,464.40","1,441.50","-","1.12%"
"Jan 07, 2000","1,441.50","1,403.50","1,441.50","1,400.50","-","2.71%"
"Jan 06, 2000","1,403.50","1,402.10","1,411.90","1,392.00","-","0.10%"
"Jan 05, 2000","1,402.10","1,399.40","1,413.30","1,377.70","-","0.19%"
"Jan 04, 2000","1,399.40","1,455.20","1,455.20","1,397.40","-","-3.83%"
"Jan 03, 2000","1,455.20","1,469.20","1,478.00","1,438.40","-","-0.95%"
```

 Now of course I could import this data set into Excel, Tableau, etc. to perform data visualization but the point of this exercise was to evaluate Jupyter notebooks which allow for not only data visualization but also data preparation ([pandas](https://pandas.pydata.org)), machine learning ([scikit-learn](https://scikit-learn.org/stable/)), etc.  In general it has greater flexibility in functionality as the design allows for computational storytelling given the free form ability to add rows of markdown mixed in with the computational rows.

 ### Creating the notebook

Most of the learning curve came while trying to undertand how to do data preparation and visualization with [pandas](https://pandas.pydata.org).  To do that I looked at the documentation on their [site](https://pandas.pydata.org/docs/) until I got a basic understanding of the steps necessary to view, clean and visualize a data frame. A neat thing about Jupyter notebooks is you can run each step independently of the rest so if some steps take a long time to complete you can run those once and iterate on subsequent steps.

 ### Exporting the notebook

Once I had a working notebook I wanted to export it so I could share it with other people easily.  The Jupyter CLI has a command called `jupyter nbconvert` with support for a variety of output formats including popular options such as RST, HTML and PDF.  Getting an HTML file is perfect as I can embed that as an iframe and share it right here in this article.  I wrote a script to automate generating HTML from a folder of 1+ notebooks, if you take out the for loops and boilerplate this is the command I ended up running to turn the `.ipynb` notebook file into `.html`.

```bash
$ jupyter nbconvert --execute --to html notebooks/stock-analysis/notebook.ipynb --stdout > static/notebook-stock-analysis.html
```

### Viewing the notebook

{{<notebook stock-analysis>}}

Looks like stocks have been doing OK.  Definitely no need for any sort of disclaimer that *past performance does not predict future results* right?

### Recap

Authoring a Jupyter notebook from scratch and understanding the core data analysis libraries did not end up being a massive learning curve so the experience was great overall.  I may use it more in the future for scenarios where Tableau is too heavy handed a solution or perhaps to glean insights using unsupervised machine learning given the right data set.  I would like to explore the JupyterLab, JupyterHub and other projects that enable authoring and publishing like Voila.