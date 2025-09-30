def best_fit(items, bin_capacity):
    bins = []
    for item in items:
        best_bin = None
        min_space_left = bin_capacity + 1
        for i, b in enumerate(bins):
            space_left = bin_capacity - sum(b)
            if item <= space_left and space_left - item < min_space_left:
                best_bin = i
                min_space_left = space_left - item
        if best_bin is None:
            bins.append([item])
        else:
            bins[best_bin].append(item)
    return bins


def next_fit(items, bin_capacity):
    bins = [[items[0]]]
    for item in items[1:]:
        if sum(bins[-1]) + item <= bin_capacity:
            bins[-1].append(item)
        else:
            bins.append([item])
    return bins


def first_fit(items, bin_capacity):
    bins = []
    for item in items:
        for b in bins:
            if sum(b) + item <= bin_capacity:
                b.append(item)
                break
        else:
            bins.append([item])
    return bins


def optimum_value(instance: list[float], capacity) -> int:
    from collections import Counter
    from collections.abc import Iterator
    from dataclasses import dataclass
    from queue import PriorityQueue

    type Bin = frozenset[float, int]

    @dataclass(order=True, frozen=True, kw_only=True)
    class Node:
        number_of_bins: int
        next_node_index: int
        bins: Bin

    def neighbors(node: Node) -> Iterator[Node]:
        updated_index = node.next_node_index + 1
        item = instance[node.next_node_index]
        old_bins = Counter(dict(node.bins))
        for old_level in old_bins:
            new_level = old_level + item
            # Avoid floating-point rounding issues
            if new_level > capacity + 1e-9:
                continue

            new_bins = old_bins.copy()
            new_bins += Counter([new_level])
            new_bins -= Counter([old_level])
            yield Node(
                number_of_bins=node.number_of_bins,
                next_node_index=updated_index,
                bins=frozenset(Counter(new_bins).items()),
            )

        new_singleton = old_bins.copy()
        new_singleton += Counter([item])
        yield Node(
            number_of_bins=node.number_of_bins + 1,
            next_node_index=updated_index,
            bins=frozenset(Counter(new_singleton).items()),
        )

    start_node = Node(next_node_index=0, number_of_bins=0, bins=frozenset())
    pqueue: PriorityQueue[Node] = PriorityQueue()
    pqueue.put(start_node)
    seen: set[Bin] = {start_node}

    while not pqueue.empty():
        node = pqueue.get()
        if node.next_node_index == len(instance):
            return node.number_of_bins
        for neighbor in neighbors(node):
            if neighbor.bins in seen:
                continue
            seen.add(neighbor.bins)
            pqueue.put(neighbor)

    return -1


import random

capacity = 10
while True:
    items = [random.randint(2, 10) for _ in range(5)]
    best_fit_score = best_fit(items, capacity)
    next_fit_score = next_fit(items, capacity)
    first_fit_score = first_fit(items, capacity)
    # Assert three distinct sizes
    if len(set(best_fit_score, next_fit_score, first_fit_score)) < 3:
        continue

    opt = optimum_value(items, capacity)
    if min(len(best_fit_score), len(next_fit_score), len(first_fit_score)) == opt:
        continue
    print(
        items,
        tuple(tuple(b) for b in best_fit_score),
        tuple(tuple(b) for b in next_fit_score),
        tuple(tuple(b) for b in first_fit_score),
        opt,
        sep="\n",
    )
    input("\n")
