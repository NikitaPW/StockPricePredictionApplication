import os
import sys
import subprocess
from datetime import datetime, timedelta
import pandas as pd
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *
from PyQt5.QtCore import *
import requests

PATH = os.getcwd()

class Window(QWidget):
    def __init__(self):
        super().__init__()
        self.title = "Stock Price Prediction"
        self.left = 300
        self.top = 300
        self.width = 600
        self.height = 600
        self.initUI()

    def initUI(self):

        label1 = QLabel('Arial font', self)
        label1.setGeometry(60, 15, 300, 32)
        label1.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        label1.setText("Stock Price Prediction")
        label1.setFont(QFont('Arial', 16))
        label1.move(115, 20)
        label1.setAlignment(Qt.AlignCenter)

        label3 = QLabel(self)
        label3.setGeometry(50, 50, 300, 32)
        label3.setText("Period for training")
        label3.setFont(QFont('Arial', 10))
        label3.move(50, 60)

        self.combobox1 = QComboBox(self)
        self.combobox1.move(50, 100)
        self.combobox1.resize(120, 30)
        comboList = ["30 + 5 days", "90 + 5 days", "365 + 5 days"]
        self.combobox1.addItems(comboList)
        self.combobox1.currentTextChanged.connect(self.dropDownValueChanged)

        label6 = QLabel(self)
        label6.setGeometry(50, 50, 100, 32)
        label6.setText("Starting date")
        label6.setFont(QFont('Arial', 10))
        label6.move(300, 60)

        self.dateedit = QDateEdit(self, calendarPopup=True)
        dateNow = datetime.now() - timedelta(days=35)
        date = QDate(dateNow.year, dateNow.month, dateNow.day)
        self.dateedit.setDate(date)
        self.dateedit.resize(120, 30)
        self.dateedit.move(300, 100)
        #self.dateedit.dateChanged.connect(self.startDateChanged)

        button5 = QPushButton("Download data", self)
        button5.move(50, 140)
        button5.resize(110, 30)
        button5.clicked.connect(self.button5_clicked)

        label4 = QLabel(self)
        label4.setGeometry(50, 50, 400, 32)
        label4.setText("Select an algorithm for solution")
        label4.setFont(QFont('Arial', 10))
        label4.move(70, 180)
        label4.setAlignment(Qt.AlignCenter)

        self.button1 = QPushButton("SVR", self)
        self.button1.move(50, 220)
        self.button1.resize(130, 50)
        self.button1.clicked.connect(self.svr_chosen)
        self.button1.setEnabled(False)

        self.button2 = QPushButton("LSTM", self)
        self.button2.move(200, 220)
        self.button2.resize(130, 50)
        self.button2.clicked.connect(self.lstm_chosen)
        self.button2.setEnabled(False)

        self.button3 = QPushButton("CNN", self)
        self.button3.move(350, 220)
        self.button3.resize(130, 50)
        self.button3.clicked.connect(self.cnn_chosen)
        self.button3.setEnabled(False)

        button4 = QPushButton("Documentation", self)
        button4.move(260, 320)
        button4.resize(100, 30)
        button4.clicked.connect(self.open_doc)

        qbtn = QPushButton('Quit', self)
        qbtn.clicked.connect(QApplication.instance().quit)
        qbtn.resize(qbtn.sizeHint())
        qbtn.move(380, 320)
        qbtn.resize(100, 30)

    def button5_clicked(self):
        now = datetime.now()
        end = str(now.year)
        if now.month < 10:
            end = end + str(now.month).zfill(2)
        else:
            end = end + str(now.month)

        if now.day < 10:
            end = end + str(now.day).zfill(2)
        else:
            end = end + str(now.day)

        timevalue = self.combobox1.currentText()
        if timevalue == '30 + 5 days':
            dateinpast = datetime.now() - timedelta(days=35)
            start = str(dateinpast.year)
            date = QDate(dateinpast.year, dateinpast.month, dateinpast.day)
            self.dateedit.setDate(date)
            if dateinpast.month < 10:
                start = start + str(dateinpast.month).zfill(2)
            else:
                start = start + str(dateinpast.month)

            if dateinpast.day < 10:
                start = start + str(dateinpast.day).zfill(2)
            else:
                start = start + str(dateinpast.day)

            self.downloadData(start, end)
        elif (timevalue == '90 + 5 days'):
            dateinpast = datetime.now() - timedelta(days=95)
            date = QDate(dateinpast.year, dateinpast.month, dateinpast.day)
            self.dateedit.setDate(date)
            start = str(dateinpast.year)
            if dateinpast.month < 10:
                start = start + str(dateinpast.month).zfill(2)
            else:
                start = start + str(dateinpast.month)

            if dateinpast.day < 10:
                start = start + str(dateinpast.day).zfill(2)
            else:
                start = start + str(dateinpast.day)
            self.downloadData(start, end)
        else:
            dateinpast = datetime.now() - timedelta(days=370)
            date = QDate(dateinpast.year, dateinpast.month, dateinpast.day)
            self.dateedit.setDate(date)
            start = str(dateinpast.year)
            if dateinpast.month < 10:
                start = start + str(dateinpast.month).zfill(2)
            else:
                start = start + str(dateinpast.month)

            if dateinpast.day < 10:
                start = start + str(dateinpast.day).zfill(2)
            else:
                start = start + str(dateinpast.day)
            self.downloadData(start, end)

    def svr_chosen(selfself):
        subprocess.call(["svrmat/SVRMenu.exe"])


    def lstm_chosen(self):
        os.system("python lstm/start.py")

    def cnn_chosen(self):
        newPath = PATH + "/cnnr"
        os.chdir(newPath)
        subprocess.call(['runme.bat'])
        os.chdir(PATH)

    def downloadData(self, start, end):
        url = 'https://stooq.com/q/d/l/?s=wig20&d1=' + start + '&d2=' + end + '&i=d&c=1'
        response = requests.get(url)
        rawData = pd.read_csv(url, delimiter=';')
        rawData['OpenMax'] = 0.0
        rawData['OpenMin'] = 0.0
        rawData['Day'] = 1
        n = len(rawData.index)
        i = 0
        min = rawData.iloc[0]['Open']
        max = rawData.iloc[0]['Open']
        while i < n:
            rawData.at[i, 'Day'] = datetime.strptime(rawData.iloc[i]['Date'],'%Y-%m-%d').weekday()+1
            if (rawData.at[i, 'Open'] > max):
                max = rawData.at[i, 'Open']
            if (rawData.at[i, 'Open'] < min):
                min = rawData.at[i, 'Open']
            rawData.at[i, 'OpenMax'] = max
            rawData.at[i, 'OpenMin'] = min
            i = i + 1
        outdir = './data'
        if not os.path.exists(outdir):
            os.mkdir(outdir)
        rawData.to_csv('data/wig20_d.csv', index=False, header=True)
        self.button1.setEnabled(True)
        self.button2.setEnabled(True)
        self.button3.setEnabled(True)

    def open_doc(self):
        os.system("notepad.exe Documentation.txt")

    def dropDownValueChanged(self):
        timevalue = self.combobox1.currentText()
        if timevalue == '30 + 5 days':
            dateinpast = datetime.now() - timedelta(days=35)
            date = QDate(dateinpast.year, dateinpast.month, dateinpast.day)
            self.dateedit.setDate(date)
        elif (timevalue == '90 + 5 days'):
            dateinpast = datetime.now() - timedelta(days=95)
            date = QDate(dateinpast.year, dateinpast.month, dateinpast.day)
            self.dateedit.setDate(date)
        else:
            dateinpast = datetime.now() - timedelta(days=370)
            date = QDate(dateinpast.year, dateinpast.month, dateinpast.day)
            self.dateedit.setDate(date)


    def startDateChanged(self, date):
        date = self.dateedit.date()
        dateinpast = date
        timevalue = self.combobox1.currentText()
        if timevalue == '30 + 5 days':
            dateinpast = date.addDays(-35)
            if date > dateinpast:
                date = dateinpast

        elif (timevalue == '90 + 5 days'):
            dateinpast = date.addDays(-95)
            if date > dateinpast:
                date = dateinpast

        else:
            dateinpast = date.addDays(-370)
            if date > dateinpast:
                date = dateinpast

        self.dateedit.setDate(date)




def main():
    app = QApplication(sys.argv)
    win = Window()
    win.show()
    sys.exit(app.exec_())


if __name__ == '__main__':
    main()
