__author__ = 'Jeevan'
'''
Credit Line Test application developed for Avant's Data Warehouse Engineer position
Program takes Apr and Credit allotted
Program takes transaction date and amount to record withdrawl or Payments

'''
from datetime import datetime
import datetime as d

'''
Credit Account class to maintain a customer apr, amount, transaction details, interest and balances
'''

class CreditAccount:
    def __init__(self,apr,limit):
        self.apr = apr/100.0
        self.limit = limit
        self.balance = limit
        self.loaned_amount = 0
        self.interest = 0
        self.transactions = []
        self.transaction_dates = []
        self.loaned_amnt_list = []

    def withdrawl(self,date,amount):
        '''
        :param date: Gets date from User
        :param amount: Gets Amount from user
        :return: Records withdrawl
        '''
        self.transaction_dates.append(date)
        self.transactions.append(amount*-1)
        self.balance = self.balance - amount
        self.loaned_amount = self.loaned_amount + amount
        self.loaned_amnt_list.append(self.loaned_amount)

    def payment(self,date,amount):
        '''
        Records Payments made by customer
        :param date: Data Payment made
        :param amount: Amount the customer paid
        :return: Records Payment
        '''
        self.transaction_dates.append(date)
        self.transactions.append(amount)
        self.balance = self.balance + amount
        self.loaned_amount = self.loaned_amount - amount
        self.loaned_amnt_list.append(self.loaned_amount)

    def find_interest(self):
        '''
        Finds the interest and total principal amount due after 30 days billing cycle
        :return:
        '''
        days_gap = [(self.transaction_dates[i+1]-self.transaction_dates[i]).days for i in range(len(self.transaction_dates)-1)]
        days_gap.append(30-self.transaction_dates[-1].day)
        days_gap[0] = days_gap[0]+1
        interest_per_day = self.apr/365.0
        interst_pair =[i*j*interest_per_day for i,j in zip(self.loaned_amnt_list,days_gap)]
        print 'Assuming that the 30 day interest period has started, Interest :',sum(interst_pair),'Total Payoff amount:',self.loaned_amount+sum(interst_pair)

    def get_account_details(self):
        '''
        Gets account details for the particular customer
        :return:
        '''
        print 'Apr',self.apr
        print 'CreditLimit',self.limit
        print 'Balance',self.balance
        print 'Loaned Amount',self.loaned_amount

    def get_all_transactions(self):
        '''
        Get the details of all customers
        :return:
        '''
        if len(zip(self.transaction_dates,self.transactions)) !=0:
            print 'Transaction Date','Transaction Amount ("-" indicates withdrawl)'
            for i,j in zip(self.transaction_dates,self.transactions):
                print i,j
        else:
            print "No Transactions to display"

if __name__ == '__main__':
    '''
    Main Program starts here. Displays various options a customer can do
    Performed various validations
    '''
    ans=True
    customer = None
    while ans:
        print ("""
        1.Create a Customer with Apr and CreditLimit (apr,amount)
        2.Record a Withdrawl(date (mm-dd-yyyy),amount)
        3.Record a Payment (date (mm-dd-yyyy),amount)
        4.Find your Interest (view available balance etc.)
        5.Show all transactions
        6.Exit/Quit the system
        """)
        ans=raw_input("What would you like to do? ")
        if ans=="1":
            apr,amount=raw_input("Enter in this format - apr,amount: ").strip().split(',')
            if float(apr) > 0 and float(amount) > 0:
                customer = CreditAccount(float(apr),float(amount))
                customer.get_account_details()
                print("\n Customer Created with the given credit and apr ")
            else:
                print "Apr or Amount should not be negative"
        elif ans=="2":
            if customer:
                data = raw_input("Record the Withdrawl - date (mm-dd-yyyy),amount: ").strip().split(',')
                # print len(data),data
                if len(data) == 2 and float(data[1]) <= customer.balance and float(data[1]) >=0:
                    date,amount = data
                    date = datetime.strptime(date,'%m-%d-%Y')
                    if len(customer.transaction_dates) == 0 or (len(customer.transaction_dates) !=0 and date >=  customer.transaction_dates[-1] and date <=  d.datetime(customer.transaction_dates[0].year,customer.transaction_dates[0].month,30)):
                        customer.withdrawl(date,float(amount))
                        customer.get_account_details()
                        print("\n Recorded Withdrawl")
                    else:
                        print "Enter a valid date that is greater than previous transaction but with in this bill month"
                else:
                    print "Error could be : 1.Date is not entered in valid format or 2. The withdrawl amount is greater than available balance"
            else:
                print "Create a Credit Line and APR first"
        elif ans=="3":
            if customer:
                data = raw_input("Record the Payment - date (mm-dd-yyyy),amount: ").strip().split(',')
                if len(data) == 2 and float(data[1]) <= customer.loaned_amount and float(data[1]) >=0 :
                    date,amount = data
                    date = datetime.strptime(date,'%m-%d-%Y')
                    if len(customer.transaction_dates) == 0 or (len(customer.transaction_dates) !=0 and date >=  customer.transaction_dates[-1] and date <=  d.datetime(customer.transaction_dates[0].year,customer.transaction_dates[0].month,30)):
                        customer.payment(date,float(amount))
                        customer.get_account_details()
                        print("\n Recorded Payment")
                    else:
                        print "Enter a valid date that is greater than previous transaction but with in this bill month"
                else:
                    print "Error could be : 1.Date is not entered in valid format or 2. The Payment amount is greater than Loaned amount"
            else:
                print "Create a Credit Line and APR first"
        elif ans=="4":
            if customer:
                customer.find_interest()
            else:
                print "Create a Credit Line and APR first"
        elif ans=="5":
            if customer:
                customer.get_all_transactions()
            else:
                print "Create a Credit Line and APR first"
        elif ans=="6":
            print("\n Goodbye")
            ans = False
        else:
            print ("\n Wrong choice, Please choose something between 1-6")