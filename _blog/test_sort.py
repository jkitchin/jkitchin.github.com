
def sort_solution(LIST):
    return LIST.sort()

def test_sort(s):
    exec s in globals()
    if sort([3, 4, 2]) == [2, 3, 4]:
        print('passed test 1')
    if sort(['z', 'b']) == ['b', 'z']:
        print('passed test 2')
