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
# Efficient Pattern Mining Methods
