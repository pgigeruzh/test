---
author: John Doe
title: Demo Slide
date: June 21, 2017
---

# Font Awesome
<i class="fas fa-user"></i>

# Quote
> Blockquotes are very handy in email to emulate reply text.
> This line is part of the same quote.
> [I'm an inline-style link](https://www.google.com)

# In the morning {data-background-color="rgb(70, 70, 255)"}

> - Turn off alarm
> - Get out of bed

# Breakfast {data-background-image="images/test.jpg"}

content before the pause

. . .

content after the pause

# In the evening

![](images/test.jpg){ width=100% }

# Code

```python
# part to end.
  
def splitArr(arr, n, k): 
    for i in range(0, k): 
        x = arr[0]
        for j in range(0, n-1):
            arr[j] = arr[j + 1]
          
        arr[n-1] = x
  
# main
arr = [12, 10, 5, 6, 52, 36]
n = len(arr)
position = 2
  
splitArr(arr, n, position)
  
for i in range(0, n): 
    print(arr[i], end = ' ')
```

# Math

$$ f(x)=x^2 $$

$$ f(x)=x^2 $$

$$ f(x)=x^2 $$

$$ f(x)=x^2 $$

$$ f(x)=x^2 $$

$$ f(x)=x^2 $$

$$ f(x)=x^2 $$

$$ f(x)=x^2 $$

# Columns

:::::::::::::: {.columns}
::: {.column width="40%"}
This is a Test
:::
::: {.column width="60%"}
This is another Test
:::
::::::::::::::

# Tables

| Tables        | Are           | Cool  |
| ------------- |:-------------:| -----:|
| col 3 is      | right-aligned | $1600 |
| col 2 is      | centered      |   $12 |
| zebra stripes | are neat      |    $1 |