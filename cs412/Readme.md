# Introduction to Data Mining - Spring 2018
January 16, 2018 (07:45:06) 
Jia Wei Han
piazza: https://piazza.com/class/jc9q3te0qoskz
course staff: cs-412ds-staff@lists.cs.illinois.edu

--- Week 1
# Pattern Discovery: Basic Concepts

## What is Pattern Discovery?

*Patterns*: set of items, subsequences,substructures that occur frequently together (or strongly correlated) in a set.  - Intrinsinc and important properties of datasets.

*Pattern discovery*: uncovering patterns from massive datasets. Foundation for many data mining tasks.

## Frequent Patterns

| id | transactions |
|----|--------------|
| 10 | B,D,N        |
| 20 | B,C,D        |
| 30 | B,D,E        |
| 40 | N,E,M        |
| 50 | N,C,E,M      |

*support*: number of occurrences

*relative support*: support / len(transactions)

*min support*: threshold of interest

*itemset*: { i } : i ∈ items 

*K-itemset*: a set of items of len(itemset)==K

*frequent*: if sup >= min_sup or rel_sup >= min_rel_sup

``` 
min_rel_sup == .5
sup(B) == 3
rel_sup(B) == 3/5 == 60% > min_rel_sup → frequent 
rel_sup(C) == 2/5 < min_rel_sup

``` 

## Association Rules

X → Y (s,c)
*s = support*: Probability that transaction supports X U Y

TODO: why call it a probability when you can directly count it?
*c = confidence*: Conditional probability that a transaction containing X also contains Y

``` 
c = sup( X U Y ) / sup ( X )
``` 
some people may think the notation is confusing because in a Venn diagram they would diagram it as an intersection, but technically correct given definition of sup (personally ok :))


### Association Rule Mining
Find all the association rules X → Y with min_sup and min_con

e.g. for our table above

min_sup = 3, min_rel_sup = 60%
``` 
sup(B,D) = 3 , rel_sup(B,D) 3/5 ✔ 
sup(B,N) = 1
... etc
``` 

min_con = .5
``` 
conf(B,D) = sup(B U D) / sup(B) = 3 / 3 = 100% ✔ 
conf(B,N) = sup(B U N) / sup(B) = 1 / 3 = 30% 
``` 

## Compressed representation: closed and max patterns

long patterns contain a combinatorial number of subpatterns. e.g:

Transactional DataBase TDB1 with T1={a_1...a_50} T2={a_1...a_100}
``` 
2-itemset: 100_choose_2  100!/2!(88!) = 4950
3-itemset: 100_choose_3  100!/3!(87!) = 161700
...
total subpatterns: 100_choose_1 + ... + 100_choose_100 = too much!
``` 

### Closed Patterns

X is a *closed pattern* if it is frequent and there is no Y : Y is frequent and contains X AND sup(Y) == sup(X)

closed patterns in TDB1 if min_sup =1
``` 
P1 = {a_1, ... ,a_50}  : sup(P1) = 2, no frequent super pattern with *same* support
P2 = {a_1, ... ,a_100} : sup(P2) = 1, no frequent super pattern with *same* support
``` 

Closed parts provide *lossless* compression, they preserve the sup of subpatterns. e.g. 
``` 
P3 = {a_2, ... a_100} is _known_ to have sup(P3) = 1 , because P2 C P3 and P2 closed pattern 
``` 

### Max Patterns

X is *max pattern* if it is frequent and there is no Y : Y is frequent and contains X
``` 
P = {a_1, ... ,a_100}  : sup(P) = 1, no frequent super pattern 
``` 

| Frequent P | sup | Closed, Max |
|--------------------------------|
| B,N,D      | 100 | C           |
| B,C,N      | 200 | C,M         |
| B,D,E      |  50 |             |
| B,N,E,M    | 400 | C           |
| B,N,D,E,M  |  50 | C,M         |

Note there can't be an M only. All Max are closed.

  
# Efficient Pattern Mining Methods
