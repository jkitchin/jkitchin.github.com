import csv

with open('contacts.csv', 'rb') as csvfile:
    spamreader = csv.reader(csvfile, delimiter=',')

    with open('new-contacts.csv', 'w') as f:
        for row in spamreader:
            if row[0]:
                f.write(','.join(row[0:5])+'\n')
                print ','.join(row[0:5])
