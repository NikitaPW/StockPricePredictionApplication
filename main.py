import os
import sys
import subprocess
from datetime import datetime, timedelta
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *
from PyQt5.QtCore import *
import requests


class Window(QWidget):
    def __init__(self):
        super().__init__()
        self.title = "Stock Price Prediction"
        self.left = 300
        self.top = 300
        self.width = 520
        self.height = 400
        self.initUI()

    def button5_clicked(self):
        now = datetime.now()
        end = str(now.year) + str(now.month) + str(now.day)
        timevalue = self.combobox1.currentText()
        if (timevalue == '30 + 5 days'):
            dateinpast = datetime.now() - timedelta(days=35)
            start = str(dateinpast.year) + str(dateinpast.month) + str(dateinpast.day)
            self.downloadData(start, end)
        elif (timevalue == '90 + 5 days'):
            dateinpast = datetime.now() - timedelta(days=95)
            start = str(dateinpast.year) + str(dateinpast.month) + str(dateinpast.day)
            self.downloadData(start, end)
        else:
            dateinpast = datetime.now() - timedelta(days=370)
            start = str(dateinpast.year) + str(dateinpast.month) + str(dateinpast.day)
            self.downloadData(start, end)

    def svr_chosen(selfself):
        subprocess.call(["svrmat/SVR.exe"])


    def lstm_chosen(self):
        os.system("python lstm/start.py")

    def cnn_chosen(self):
        savedPath = os.getcwd()
        newPath = savedPath + "/cnnr"
        os.chdir(newPath)
        subprocess.call(["app-starter.exe"])
        os.system("cd ../")

    def downloadData(self, start, end):
        url = 'https://stooq.com/q/d/l/?s=wig20&d1=' + start + '&d2=' + end + '&i=d&c=1'
        response = requests.get(url)
        with open('data/wig20_d.csv', 'wb') as f:
            f.write(response.content)

        self.button1.setEnabled(True)
        self.button2.setEnabled(True)
        self.button3.setEnabled(True)


    def open_doc(self):
        os.system("notepad.exe Documentation.txt")

    def initUI(self):

        label1 = QLabel('Arial font', self)
        label1.setGeometry(60, 15, 400, 32)
        label1.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        label1.setText("Stock Price Prediction")
        label1.setFont(QFont('Arial', 16))
        label1.setAlignment(Qt.AlignCenter)

        label3 = QLabel(self)
        label3.setGeometry(50, 50, 400, 32)
        label3.setText("Please choose a period for training")
        label3.setFont(QFont('Arial', 10))
        label3.move(50, 60)

        self.combobox1 = QComboBox(self)
        self.combobox1.move(50, 100)
        self.combobox1.resize(120, 30)
        comboList = ["30 + 5 days", "90 + 5 days", "365 + 5 days"]
        self.combobox1.addItems(comboList)

        button5 = QPushButton("Download data", self)
        button5.move(50, 140)
        button5.resize(110, 30)
        button5.clicked.connect(self.button5_clicked)

        label4 = QLabel(self)
        label4.setGeometry(50, 50, 400, 32)
        label4.setText("Select an algorithm for solution")
        label4.setFont(QFont('Arial', 10))
        label4.move(50, 180)

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


def main():
    app = QApplication(sys.argv)
    win = Window()
    win.show()
    sys.exit(app.exec_())


if __name__ == '__main__':
    main()
