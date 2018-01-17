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
|------------|-----|-------------|
| B,N,D      | 100 | C           |
| B,C,N      | 200 | C,M         |
| B,D,E      |  50 |             |
| B,N,E,M    | 400 | C           |
| B,N,D,E,M  |  50 | C,M         |

Note there can't be an M only. All Max are closed.


# Efficient Pattern Mining Methods

## Downward closure property

*Apriori* or *downward closure property*: Any subset of a frequent pattern is frequent.

conversely, if there is a subset that is not frequent, S is not.

Scalable minin methods:
 - Apriori
 - Vertical data format: eclat
 - FPGrowth

## Apriori algorithm

 - Scan db once to get frequent  1-itemset (k=1)
 - generate k+1 length candidate itemsets
 - test candidates to find frequent k+1 itemsets (actually PRUNE non-candidates)
 - repeat until no frequent items can be iterated

## Self joining and pruning

In practice the key questions are *how to generate candidates* and *how to test them*.

*Self joining* for generation - *the JOIN step*:

```
Frequent 3-itemset patterns F3 = {abc, abd, acd, ace, bcd }

F3 * F3 : abc U abd = {abcd} +
          abc U acd = {abcd} +
		  acd U ace = {acde} +
		   ...

```

Note that  bcd U ace = {abcde} is not part of the join. We are looking only for k+1 itemsets.
In practice the ```*``` opererator in this notation means: "assuming each transaction in the set has its items ordered in lexicographical order join those that are similar up to the first k-1 items."

Downward closure for testing - *the PRUNING step*:

```
Generate k-1 subsets for every candidate, if one is not in frequent (in Fk-1), remove it.

```

## SQL pseudocode implementation (from slides not assignment)

```SQL
;;Suppose Fk-1 items are listed in order

;;step 1 - Self Joining:
INSERT into Ck
    SELECT p.i1, pi2, pi3, pi4, qi5 ;; notice q
	FROM Fk-1 as p, Fk-1 as q
	WHERE p.i1 = q.i1, p.i2 = q.i2, ..., pk-1 < qk-1

;;step 2 - Pruning:
for all item sets c in Ck :
   for all (k-1) subsets s of c:
      if (s is not in Fk-1) delete from Ck
```

## Extensions or improvements to Apriori

 - Reduce number of scans (lots of I/O)
    - *Partitioning* (discussed in course)
	- Dynamic itemset (google guy)
 - Shrink number of candidates
    - *Hashing method* (discussed in course)
	- Pruning by lower binding
	- Sampling
 - Use special data structures:
    - *FPTree for FPGrowth* (discussed in course)
    - H Tree for H Mine
	- Tree projectiono

## Partitioning

Only have to scan twice.

*Key observation*: any itemset that is potentially frequent in TDB must be frequent in at least one partition.

This implies that a local candidate may not be frequent in the whole db, but every frequent candidate must be a local frequent somewhere.

```
Method:
 - Scan 1: Partition database into size of RAM to find local frequents → local candidates
 - Scan 2: Consolidate global frequent patterns by taking all the local candidates and counting their support against the whole database (whence second scan) - prune those not frequent enough.
```

## Direct hashing and pruning

try to reduce number of candidate items

*Key observation*: a k-itemset whose hashing bucket count is below a threshold cannot be frequent.

```
Method:
 - Given k itemset make a hash table such that *several* k+1 items share the same bucket.
 - Count the number of hits to that hash. If it is below a threshold you can discard all the items in that bucket.

```

## Vertical Data Format ECLAT
(Note not really an optimization on apriori, kind of an interim before third optimization, FPGrowth)

Equivalence Class Transformation, *ECLAT*,


```
| Tid | Itemset |		  | Item | TidList  |
|-----+---------|		  |------+----------|
|  10 | a,c,d,e |  	→ →   | a    | 10,20    |
|  20 | a,b,e   |	  	  | b    | 20,30    |
|  30 | b,c,e   |	  	  | c    | 10,30    |
					  	  | d    | 10       |
					  	  | e    | 10,20,30 |

```

t(a) simple O(1): {10,20}

To derive list of of ids t of a combination, e.g. t(ae) we take the intersection:

t(ae) = {10,20,30} intersect {10,20} = {10,20}

*key properties:* 
 - t(x) = t(y) → x and y always happen together
 - t(x) subset of t(y) →  transaction having X always has Y
 
 The support for an entry is simply len(TidList)
 
 You can look for frequent patterns by intersecting items:
 
 | a,b |    20 |
 | a,c |    10 |
 | a,d |    10 |
 | a,e | 10,20 |

which of these have support larger than 1? easy a,e.

Tradeoff here is Tid sets can be very long. Expensive intersects and expensive in memory. The approach is to use *diffset* to keep track of the difference rather than intersection of ids.

## FPGrowth - Pattern Growth Approach

TODO: FPGrowth

Two relatively unexplained corollaries:
 - In a single path prefix situation the mining can be decomposed into prefix mining and branches, afterwards concatenating the results.
 - In case of data too big for memory, Partition can be done either by projection or partition (not detai (not really detailed in course, pg. 259)
