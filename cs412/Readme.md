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
| Tid | Itemset |         | Item | TidList  |
|-----+---------|         |------+----------|
|  10 | a,c,d,e |   → →   | a    | 10,20    |
|  20 | a,b,e   |         | b    | 20,30    |
|  30 | b,c,e   |         | c    | 10,30    |
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

The first step same as a priori: generate a list L of 1-itemset frequent patterns and their frequency. Order it.

To construct an FPTree go through the whole database a second time, creating a tree with a branch per transaction, considering each itemset in L order. for example


```

        TID             L                   FPTree
                                                {}          {}              {}
| t1 | i1,i2,i5 |   | i2 | 4 |               i2 : 1       i2 : 2        i2: : 3 __
| t2 | i2,i4    |   | i1 | 2 |               /            /   \         /     \    ---\
| t3 | i2,i3    |   | i4 | 2 |               i1: 1             i1: 1 i4: 1    i1: 1  i4: 1  i3: 1
| t4 | i1,i2,i4 |   | i5 | 1 |             /            /             /
                                         i5: 1       i5: 1         i5 : 1

                                                      after processing t1 , t2, t3 respectively
```

once the tree is constructed mining is reduced to creating "conditional databases", by considering each member of L a suffix and recording the branches as candidates in the conditional database.
This is done starting in reverse L order. for example for i5 (with more items, see page 258) we end up with two paths

{i2,i1,i3}:1
{i2,i1}:1

and then we construct another FPTree based on this (where i2 and i1 would end up with count two and i3 of 1. That single path is one of the stop cases of the recursion (The other emptiness) and generates all combinations of frequent patterns with i5.

Two relatively unexplained corollaries in the slides made a bit clearer by pg 258:
 - In a single path prefix situation the mining can be decomposed into prefix mining and branches, afterwards concatenating the results.
 - In case of data too big for memory, Partition can be done either by projection or partition (not really detailed in course, pg. 259)

NOTE: questions about FPtrees usually require deriving the x-conditional database (conditional pattern bases) given a tree:

```
FPTree                                                    Resulting conditional pattern bases
{}    
 - f:4                                                       c f:3
   - c:3                                                     a fc:3
     - a:3                                                   b f:1, c:1
       - b:1                                                 p cb:1 fcam:2
          -m:1                                               m fca:2, fcab:1
     - m:2
       - p:2
     - b:1
       - m:1
  - c:1
     - b:1
       - p:1
```

## Mining closed datasets with CLOSET+

Just a mention to efficient mining of closed datasets by using clever observations, implemented in a system called closet+. An example is if closed pattern Y appears every time X appears, Y can be merged into X.  Others not detailed.

--- Week 2
# Pattern Evaluation

Evaluation can be subjective too: query based, against specific knowledge base (e.g. looking for freshness or unexpected), or interactive visual explorations.

Limitations of Support/confidence

|                | play ball | not play ball | sum row |
| eat cereal     |       400 |           350 |     750 |
| not eat cereal |       200 |            50 |     250 |
| sum col        |       600 |           400 |    1000 |


```
ball → eat
s = sup(X U Y) = 400/1000
c = sup(X U Y) / sup (X) = 400/600
```

play ball → eat cereal [40%,11.7%]

seems good, high s,c. but notice
```
no ball → eat
s = 350/1000
c = 350/400

```
not play ball → eat cereal [35%,87.5%] pretty good looking too.
They support mutually exclusive reactions. we need other ways of evaluating.


## Lift and χ2

### Lift
Lift (B,C) = c(B,C) / S(c)  = sup(B U C) / (sup(B) * sup(C))

Lift (B,C) = 1  B and C independent
           > 1  positively correlated
		   < 1  negatively correlated

Range of lift is [0, inf)

```
Lift(play,eat): 4/10  / (6/10 * 75/100)         = 0.88  < 1 negatively correlated

Lift(play,not eat): 200/1000 / (6/10 * 250/1000) = 1.33  > 1 positively correlated
```

Solves our problem becasue we can tell one is positively correlated and one is negatively.

### χ2

χ2 = sum_of( (observed - expected )^2/expected )

χ2 = 0 independent
   > 0 correlated, don't know which

Range of χ2 is [0,inf)

Notice the expected value (given the proportion of the row to to totals) added.
For example the proportion of all Cs to the total is 3/4. Out of 600 Bs we would expect 3/4 to b C:
600*3/4 = 450

|         | B         | not B     | sum row |
| C       | 400 (450) | 350 (300) |     750 |
| not C   | 200 (150) | 50 (100)  |     250 |
| sum col | 600       | 400       |    1000 |


χ2 is calculated over the full table:

χ2 = (-50)^2/450 + 50^2/300 + (50^2)/150 + (-50)^2/100  = 55.6

we expect them to be correlated but we see C is less than expected so it most be negatively correlated. This is consistent with Lift.

### Too many Null transactions spoil Lift and χ2

|         |    B |  not B | sum row |
| C       |  100 |   1000 |    1100 |
| not C   | 1000 | 100000 |  101000 |
| sum col | 1100 | 101000 |  102100 |

Lift (B,C) is very high 8.4 >> 1 so they should be positively correlated

But this doesn't seem right given that 100 is much less than (B,not C)=100000
and (not B,not C) 1000000. (B,C) actually appears to be pretty infrequent, making an association based on it seems incorrect.

_too much tuna!_ [not b,not c ] are the null transactions.

Note: Basically my intuition here is that whatever the real gold is, it shall be found in the
100000 that are neither "hidden" from this table.


χ2 also fails. χ2 = 670 suggesting strong correlation but
the observed value (B):100 >> expected (B):11.85 so is it really correlated?

TODO: the fail of χ2 is less obvious. Clarify

## Null invariant measures

Lift and χ2 greatly affected by null transactions.Not just by many null transactions but by very few . Simply not null invariant.

Other measures are null invariant. They are listed in page 269 and include:

 - all_conf
 - Kulczynski (recommended along with Imbalance ratio)
 - cosine
 - max_conf

They are all null invariant and in range [0,1]

# Imbalance Ratio

IR(A,B) = |S(A) - S(B)| / (S(A) + S(B) - S(A U B))

IR range is [0,1] the higher the more imbalanced. 0 balanced

Kulcynski and imbalance ratio present a clear picture

# Mining diverse frequent patterns

A mostly-conversational survey of variations.

## Multi-levels

given a patterns within a logical hierarchy e.g.

```
milk: sup 10
    skim milk: sup 6%
	     Brank X: sup 2%
		 ...
    whole milk: sup 4%
```

You could have a *uniform* support threshold but either loose smaller patterns at the bottom with a high threshold or get too many patterns with a low one.

*shared multi-level mining*: Instead we can have multiple, *reduced* levels of support and computer on one level with one threshold and with a smaller one in another.

Note when we *generate* candidates for lower level we use the suppor for that level

## Redundancy Filtering

Two association rules may be redundant if the s is close to the expected value given the ancestor, and c is very close to each other.

```
A: milk->bread(8%,70%)
B: skim milk->bread(2%,72%)
```
Since skim milk makes up for a 1/4 of all milk sold, we can derive B from A, and just remove it.

## Customized minsup for different items

Infrequent but interesting items may be filtered out very quickly under a global threshold. e.g. the dude that buys a rolex in costco.

One method is to have group-based "individualized" thresholds for groups of products. Algorithms don't change

## Multi dimensional rules

[buys product] milk  → [buys product] eggs                           -- Single dimension
[age]          18-25 AND [occupation] student → [buys product] eggs  -- Interdimensional
[age]          18-25 AND [buys product] pancakes → [buys product] eggs  -- Hybrid, repeated predicates

Attributes can be categorical or numerical:
 - Categorical such as profession, product have no inherent order . We can data cube directly
 - Numerical: age, salary, etc. Discretization, clustering, gradient to create groups

## Mining quantitative associations

Age, salary as exact numbers are useless (too specific). We need groups:
 - Statistical discretization on predefined concept hierarchies
 - Dynamic discretization according to need
 - Clustering
 - Deviation analysis (e.g. how far from the mean etc.)

## Mining extraordinary patterns

Gender = Female → Wage = mean $7 (overall mean $9!)

LHS a subset of the population
RHS an extraordinary behavior of this subset

Rule accepted only if 2 test fonfirms the inferene rule

## Mining negative correlations

rare is low support but interesting - individualized minsup
*negative* is different: negatively correlated, unlikely to happen together (?likely to NOT?)

Buy prius →  buy hummer

### Negative correlated patterns

A *support-based definition* may end up sounding a lot like lift and having the same trouble with null transactions:

if itemsets A and B are both freq but rarely occur together

```
sup( A U B ) << sup( A ) x sup( B )
```

then A and B are negatively correlated.

In a case with lots of null transactions, say 10^6 total transactions you may find them incorrectly positively correlated:

```
1/10^6 > 1/10^3 * 1/10^3

```

A *null-invariant* definition based on kulzcynski is better:

If itemsets A and B are both frequent but the average of their conditional probabilities is below a threshold:

```
((P(A|B) + P(B|A))/2 <  ε
```

where ε is a negative pattern threshold then A and B are negatively correlated.

```
P(B|A) = P (B U A) / P(A)

```

## Mining Compressed patterns

We want a balanced between closed patterns, which have too much emphasis on support and no compression and max patterns, which have lots of compression but a lot of data loss.

The concept is pattern distance:

```
dist(P1,P2) = 1 - | T(P1) ∩ T(P2) | / | T(P1) U T(P2) |

```
based on this we can do delta clustering:
*δ clustering*: represent several p as P if P contains them and are at distane within δ. All patterns in that cluster represented by P

## Redundancy aware top-k patterns

Basically you don't want just significance because you may ignore whole clusters and you don't want just relevance by cluster because you may obscure important signicance legitimately accumulated in a cluster.

more detail and diagram pg 311.

## Mining collosal patterns with Pattern Fusion

Methods so far only good for patterns length < 10. Because of downward closure there are too many subsets (Small number for 1-itemsets, larger for 2, etc..)

Pattern Fusion (304) is a method to *jump* from a small (e.g. level-3) set of traditionally generated patterns to collosal patterns without having to explicilty visit the swamp of mid-set patterns.

Pattern fusion doesn't strive for completion just to get almost complete and represented in the colossal.

The *key observation* is this: the larger the pattern the more likely to be generated from smaller patterns. A collection of smaller patterns hint at a larger pattern. Try them out.

### Example

Dataset D contains only 4 colossal patterns:

{a1,a2,...,a50}: sup 40
{a3,a6,...,a99}: sup 60
{a5,a10,...,a95}: sup 80
{a10,a20,...,a100}: sup 100

If you check pattern pool of size 3 you may find

{a2,a4,a5}: ~40  {a3,a34,39}: ~40 {a5,a15,a85}: ~80

If we pick at random from size c we are more likely to get core patterns or their descendants and use them to generate candidate colossals. (this is slightly hazy but better explained in pg 304)

### core patterns and robustness

for a frequent pattern alpha, a subpattern beta is a *tao-core pattern* if beta shares a similar support set with a:

```
 | D(alpha) | / | D(beta) | >= tao  0 < tao <=1 where tao is called the core ratio, |Dx| the number of patterns containing x.

```

*robustness*: a patterns is (d,tao)-robust if d is the maximum amount of items that can be removed _from alpha_ such that the resulting pattern is still tao-core of alpha

for a (d,tao) robust pattern of alpha, it has ("in the order of") omega(2^d) core patterns.

Robustness of colossal patterns: a colossal patterns tends to have much more core patterns than small patterns.

Patterns can be clustered together to form "dense balls" based on distance.

### Pattern-fusion Algorithm itself

 - traditional up to small size e.g.3
 - at each iteration pick K seed patterns randomly picked from pattern pool
 - for each in K find all the patterns within a bounding ball centered at the seed pattern
 - fuse the patterns in the ball to generate candidate super patterns
 - test super patterns, use the good ones for the next iteration

 terminate when the current pool contains no more K patterns at the beginning of that iteration.

--- Week 3

# Sequential patterns and Sequential pattern mining

Lots of applications: genome sequences, click streams, copy/paste in sw bugs etc. Gapped and non-gapped seq patterns.

## Sequential pattern mining

Find the complete set of frequent subsequences

| SID | Sequence          |
|-----|-------------------|
|  10 | <a(abc)(ac)d(cf)> |
|  20 | <(ad)c(bc)(ae)>   |
|  30 | <(ef)(ab)(df)cb>  |
|  40 | <eg(af)cbc>       |


*Sequence*: an ordered set of elements
*Elements*: a set of items . We represent them lexicographically ordered for convenience.

*Subsequence*: <a(bc)dc> sub of <a(abc)(ac)d(cf)>

Notice these are not regexps is not like you have to have one of the ones in parentheses. In fact you can "chop off" full items and have a subsequence. For example:

Given minsup=2 and the table above, <(ab)c> is a *sequential pattern*

- the (ab) in <(ab)c> matches the second item of SID 10.
- the c in <(ab)c> matches the third item of SID 10.

Notice they are more like "item requirements". The way to read it in english would be "(ab) together followed by c"

Apriori hold: S1 not frequent, then no super-sequence of s1 can be frequent

## Algorithms

  - GSP: generalized sequence patterns
  - Spade: vertical format based
  - Prefix span: pattern growth method

  - CloSpan: Closed seq pattern algorightms

## GSP

 - Initial candidates: singletons
 - Scan DB count support discarding those below threshold (because apriori)
 - generate length-2 candidates:
   - all combos of items with themselves
   - n choose k

Note that in our example since we discarded apriori two singletons we didn't get 92 length-2 candidates but only 51.

## SPADE

Sequential in vertical format.

 - Convert from seq db to vertical format
 - Combine by looking at order (smaller indexes)

| SID | Sequence          |
|-----|-------------------|
|   1 | <a(abc)(ac)d(cf)> |
|   2 | <(ad)c(bc)(ae)>   |
|   3 | <(ef)(ab)(df)cb>  |
|   4 | <eg(af)cbc>       |

| SID | EID | Items |
|-----|-----|-------|
|   1 |   1 | a     |
|   1 |   2 | abc   |
|   1 |   3 | ac    |
|   1 |   4 | d     |
|   1 |   5 | cf    |
|   2 |   1 | ad    |
|   2 |   2 | c     |
|   2 |   3 | bc    |
|   2 |   4 | ae    |
|   3 |   1 | ef    |
|   3 |   2 | ab    |
|   3 |   3 | df    |
|   3 |   4 | c     |
|   3 |   5 | b     |
|   4 |   1 | e     |
|   4 |   2 | g     |
|   4 |   3 | af    |
|   4 |   4 | c     |
|   4 |   5 | b     |
|   4 |   6 | c     |

from there we can do the tables for each singleton:

For "a":

| SID | EID |
|-----|-----|
|   1 |   1 |
|   1 |   2 |
|   1 |   3 |
|   2 |   1 |
|   2 |   4 |
|   3 |   2 |
|   4 |   3 |

for "b":

| SID | EID |
|-----|-----|
|   1 |   2 |
|   2 |   3 |
|   3 |   2 |
|   3 |   5 |
|   4 |   5 |

we can combine by looking at order, using the indexes:

for "ab"

| SID | EID a  less than    | EID b |
|-----|---------------------|-------|
|   1 |                   1 |     2 |
|   2 |                   1 |     3 |
|   3 |                   2 |     5 |
|   4 |                   3 |     5 |


and so on...

## Prefix Span

By pattern growth. Introduce prefix and suffix
given <a(abc)(ac)d(cf)> you can say

| Prefix | Suffix           |
|--------|------------------|
| <a>    | <(abc)(ac)d(cf)> |

also you can say
prefix <aa> suffix <(_bc)(ac)d(cf)> but that is less clear.

For the algorithm itself start with singletons (<a>, <b>, etc). This will generate a table of suffixes for each.

Look at the length-k+1 sequential patterns <aa> <ab> and advance by divide and conquer: if they are frequent on the projected DB, continue.

Main advantage is there are no candidates generated and db keeps shrinking. also pointer implementation tricks help representation keep compact in memory

## CloSpan

Closed pattern if there is no super pattern with the *same* support.

We are interested b/c reduce number of redundant patterns. Attain same expressive power with losless compression

Key observation: s super_of s1 if two projected dbs have same size (not very clear how that is true or translates but merely mentioned.


```
       *                   *
      / \                 / \
    a     f              a  f
   /      .             /   /
  f      ...           f <-'
  .     .....          .
 ...                  ...
.....                .....

```

# Graph pattern and mining

Basically analogous ideas and breakdown similar to transaction and sequence patterns, namely you can do apriori (BFS) or pattern growth (DFS) and support, as usual, the proportion of occurrences

given DG = { G1, G2, G3 }
sup G = | DGi| / | DG| where DGi is subset of DG such that Gi contains g

## Breakdown of algorithms

  - By generation of candidate subgraphs
   - apriori vs pattern growth
  - By search order
   - breadth vs depth
  - By how they eliminate duplicate subgraphs
   - passive vs active
  - By support calculation
  - Order of pattern discovery
   - path → tree → graph

## Apriori method for graph mining

Key observation: antimonotonicity: g size K is frequent iff all subgraphs are frequent

in each iteration:
 - take size k frequent graphs
 - take pair that share k-1 edges (or vertices) and join them
 - (note that the result is going to be a k+1 size)
 - (note there are many ways to join them given that two nodes can be considered equivalent)
 - Check first if antimonotonicity holds, i.e. if taking an edge (or vertex) at a time, the resulting subgraph is still frequent.
 - Notice you have to do this only with k-1 subgraphs since you already did it by construction on smaller order graphs
 - If all the subgraphs are frequent you can check for frequency of the whole candidate

## Generating new candidates

Notice there are many ways to join two k-sized graphs that differ only by one vertex, if you are to take nodes of the same value as equivalent.

```

      D                 E                D    E             D E              E
      |                 |                |    |              \|              |
 c----c            c----c                c----c          c----c         c----c
 |    |            |    |                |    |          |    |         |    |
 |    |     +      |    |       → →      |    |          |    |         |    |
 c----c            c----c                c----c          c----c         c----c
                                                                        |
                                                                        D

```

AGM is one strategy, one vertex at the time
FSG is another, one edge at the time

## gSpan - Pattern growth approach

It is pretty clear that all apriori aproaches are BFS, you get first all the breadth of k-size frequent patterns before treating k+1 candidates.

gSpan, as with the other pattern growth approaches is the DFS version. It is not clear from the slides exactly who you go from k to k+1 edges, just mentions duplicate graphs are a problem.

Since duplicates are a problem, the *key observation* is: define an order to generate subgraphs.

You create such order by doing a DFS Spanning tree: flatten a graph into a sequence using depth-first search.

Then you record the *right-most path extension* as a sequence and use that sequence to drive growth of the tree from k to k+1 (details elided)

The right-most path extension works like this:

Given a spanning tree (a tree subgraph of the graph that uses the minimum number of edges) that gives each node an index, you can generate a sequence, starting at node 0, such that you every time you follow the smallest index node available:


```               -----
               ..(  0  ).....                            e0: (0,1)
              ..  --+--     ..                           e1: (1,2)
            ...     |        ..                          e2: (2,0)
            ..    -----       ..                         e3: (2,3)
           ..    (  1  )       .                         e4: (3,0)
           ..     --+--       ..                         e5: (2,4)
          ..        |         ..
          ..      -----      ..
          ...    (  2  ) \...
           ..     --+--   \
            ..      |      \-
            ...   -----      \  -----
              ...(  3  )      \(  4  )
                  --+--         --+--
``` 
The paper proves (not seen) that the enumeration of graphs using right-most path extension is complete.

The slides also mention that given a DFS code you can mine the graph essentially as you would a set of sequences (somewhat intuitive but completely unexplored)

## CloseGraph: Mining closed graph patterns

Same motivation as before: too much tuna. In an n-edge frequent subgraph you may have 2^n subgraphs

So again, deal only with closed frequent graphs.

A frequent graph G is *closed* iff there is no supergraph of G that carries the same support as G.

Also again, lossless compression.

### CloseGraph : expansion of gSpan

the *key question* is, at what point of in the process of going from k-edge to k+1 edge do we want to stop searching the children and early-terminate?

``` 

k         k+1

      →    g1  ✔ 
g     →    g2 no
      →    g3 no

``` 
The idea is if g and g1 are frequent and g is a subgraph of g1 (gspan) AND if in any part of the graph where g occurs g1 also occurs, then we don't need to grow g in any other way.

Apparently some edge cases not detailed are possible.

### Applications and performance

The quality of the results is lossless as compared with mere frequent patterns but orders of magnitude smaller, making the results more valuable.

Also, it is way faster, orders of magnitude faster. 

For large sets, mining closed patterns is key.

## SpiderMine: mining top-K large structural patterns in a massive network




TODO: - GSP production of candidates
TODO: - Generation of projections with placeholders _. Exactly how to interpret
TODO: review for a single branch FPTree how the final patterns are generated, is this the only stop condition for the recursion?
