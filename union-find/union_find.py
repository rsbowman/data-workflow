import sys, random, itertools
from pprint import pprint
from collections import defaultdict

class Node(object):
    def __init__(self, val):
        self.val = val
        self.children = []

    def height(self):
        if self.children:
            return 1 + max(c.height() for c in self.children)
        else:
            return 1

    def to_str(self):
        if self.children:
            cld_str = " ".join(c.to_str() for c in self.children)
            return "(Node {} {})".format(self.val, cld_str)
        else:
            return "(Node {})".format(self.val)

class UnionFind(object):
    def __init__(self, size, shorten_paths=True, balance_tree=True):
        self.parents = range(size)
        self.sizes = [1] * size
        self.shorten_paths = shorten_paths
        self.balance_tree = balance_tree
        self._roots = set()

    def root(self, i):
        p = i
        while p != self.parents[p]:
            p = self.parents[p]
        if self.shorten_paths:
            c = i
            while c != p:
                old_parent = self.parents[c]
                self.parents[c] = p
                c = old_parent
        return p

    def union(self, v1, v2):
        r1 = self.root(v1)
        r2 = self.root(v2)
        if self.balance_tree:
            if self.sizes[r1] < self.sizes[r2]:
                self.parents[r1] = r2
                self.sizes[r2] += self.sizes[r1]
            else:
                self.parents[r2] = r1
                self.sizes[r1] += self.sizes[r2]
        else:
            self.parents[r1] = r2

    def eq_classes(self):
        ## don't bias our numbers by flattening ALL the paths...
        self.shorten_paths = False
        eqc = defaultdict(list)
        for i in range(len(self.parents)):
            r = self.root(i)
            self._roots.add(r)
            eqc[self.root(i)].append(i)
        return eqc

    def pretty_str(self, omit_small=True):
        s = []
        for cls in self.eq_classes().values():
            if len(cls) > 1:
                s.append(str(cls))
        return "{" + ", ".join(s) + "}"

    def make_tree(self, root):
        n = Node(root)
        self._seen.add(root)
        for i in range(len(self.parents)):
            if i in self._seen:
                continue
            if self.parents[i] == root:
                n.children.append(self.make_tree(i))
        return n

    def forest(self):
        f = []
        self._seen = set()
        for r in self._roots:
            f.append(self.make_tree(r))
        return f

#####
# functions for making histograms, formatting list to be pretty, etc.

def make_hist(array):
    hist = defaultdict(int)
    for v in array:
        hist[v] += 1
    return hist

def hist_str(hist):
    keys = sorted(hist.keys())
    s = []
    for key in keys:
        s.append("  {}: {}".format(key, hist[key]))
    return "\n".join(s)

def grouper(n, iterable, fillvalue=None):
    "grouper(3, 'ABCDEFG', 'x') --> ABC DEF Gxx"
    args = [iter(iterable)] * n
    return itertools.izip_longest(*args, fillvalue=fillvalue)

def format_list(l, width=80):
    s_list = ["({:>4}, {:>4})".format(x, y) for (x, y) in l]
    r = []
    for line_lst in grouper(8, s_list):
        r.append(", ".join(e for e in line_lst if e is not None))
    return "\n".join(r)

def main(argv):
    if len(argv) < 3:
        print "usage: {} n n_identifications".format(argv[0])
        return 0
    n = int(argv[1])
    n_identifications = int(argv[2])
    identifications = set()
    for i in range(n_identifications):
        # x = i
        x = random.randint(0, n - 1)
        y = random.randint(0, n - 1)
        if x == y:
            continue
        identifications.add((x, y))

    is_big = n > 3000

    print "identifying elements of [0, {}) by {} random tuples:".format(n, n_identifications)
    if not is_big:
        print "identifications: "
        print format_list(identifications, width=60)
        print
    ## play around with the last two arguments, which control path
    ## shortening and tree balancing, respecitvely
    uf = UnionFind(n, True, True)
    for x, y in identifications:
        uf.union(x, y)
    eq_class_sizes = sorted(len(cls) for cls in uf.eq_classes().values())
    print "eq class sizes hist:"
    print hist_str(make_hist(eq_class_sizes))
    print
    print "equivalence classes (leaving out ones of size 1):"
    print uf.pretty_str()
    f = uf.forest()
    print
    print "tree heights hist (number of trees of given height):"
    print hist_str(make_hist(t.height() for t in f))

    max_tree_height = max(t.height() for t in f)
    if not is_big:
        print "trees in union find structure of height > 2 (max height {}):".format(
                max(t.height() for t in f))
        for t in f:
            if t.height() > 2:
                print "Height {}: {}".format(t.height(), t.to_str())
                print '---'
    else:
        print "biggest trees found:"
        for t in f:
            if t.height() >= max_tree_height - 1:
                print "Height {}: {}".format(t.height(), t.to_str())
                print '---'
        return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv))
