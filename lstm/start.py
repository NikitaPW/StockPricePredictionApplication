import os
import sys
import parameters
from parameters import *
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *
from PyQt5.QtCore import *
import PyQt5.QtCore as QtCore
from stock_prediction import create_model, load_data
from tensorflow.keras.callbacks import ModelCheckpoint, TensorBoard
import matplotlib
matplotlib.use('Qt5Agg')
import matplotlib.pyplot as plt
import ntpath
import numpy as np


class Window(QWidget):
    textModified = QtCore.pyqtSignal(str, str)  # (before, after)
    def __init__(self):
        super().__init__()
        self.title = "LSTM for Stock Price Prediction"
        self.left = 200
        self.top = 200
        self.width = 500
        self.height = 500
        self.initUI()

    def initUI(self):
        label1 = QLabel('Arial font', self)
        label1.setGeometry(15, 15, 300, 32)
        label1.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        label1.setText("LSTM for Stock Price Prediction")
        label1.move(75, 15)
        label1.setAlignment(Qt.AlignCenter)
        label1.setFont(QFont('Arial', 16))

        label2 = QLabel('Arial font', self)
        label2.setGeometry(15, 15, 150, 20)
        label2.move(50, 50)
        label2.setText("Model name:")
        label2.setFont(QFont('Arial', 10))

        self.textboxName = QLineEdit(self)
        self.textboxName.setGeometry(50, 50, 150, 20)
        self.textboxName.setText(f"{parameters.date_now}_{parameters.ticker}-{parameters.LOSS}-{parameters.CELL.__name__}-seq-{parameters.N_STEPS}-step-{parameters.LOOKUP_STEP}-layers-{parameters.N_LAYERS}-units-{parameters.UNITS}")
        # label3.setText("Here the flow of the program will be displayed. \nTraining... Trained. Testing... Tested. \nThe prediction is: ")
        self.textboxName.setFont(QFont('Arial', 7))
        self.textboxName.move(50, 75)
        self.textboxName.textChanged.connect(self.changeName)

        label3 = QLabel('Arial font', self)
        label3.setGeometry(15, 15, 120, 20)
        label3.move(250, 50)
        label3.setText("Number of layers:")
        label3.setFont(QFont('Arial', 10))

        self.splayers = QSpinBox(self)
        self.splayers.setGeometry(50, 50, 150, 20)
        self.splayers.valueChanged.connect(self.numberOfLayersChanged)
        self.splayers.setValue(3)
        self.splayers.setMinimum(2)
        self.splayers.setMaximum(20)
        self.splayers.move(250, 75)

        label4 = QLabel('Arial font', self)
        label4.setGeometry(15, 15, 120, 20)
        label4.move(50, 115)
        label4.setText("Number of Units:")
        label4.setFont(QFont('Arial', 10))

        self.spunits = QSpinBox(self)
        self.spunits.setGeometry(50, 50, 150, 20)
        self.spunits.valueChanged.connect(self.numberOfUnitsChanged)
        self.spunits.setMinimum(1)
        self.spunits.setValue(12)
        self.spunits.setMaximum(128)
        self.spunits.move(50, 140)

        label5 = QLabel('Arial font', self)
        label5.setGeometry(15, 15, 120, 20)
        label5.move(250, 115)
        label5.setText("Number of epochs:")
        label5.setFont(QFont('Arial', 10))

        self.spepochs = QSpinBox(self)
        self.spepochs.setGeometry(50, 50, 150, 20)
        self.spepochs.valueChanged.connect(self.numberOfEpochsChanged)
        self.spepochs.setMinimum(1)
        self.spepochs.setMaximum(100000)
        self.spepochs.setValue(300)
        self.spepochs.move(250, 140)

        label6 = QLabel('Arial font', self)
        label6.setGeometry(15, 15, 120, 20)
        label6.move(50, 170)
        label6.setText("Select a dataset:")
        label6.setFont(QFont('Arial', 10))

        self.filename = QTextEdit(self)
        self.filename.setGeometry(50, 50, 250, 20)
        self.filename.setText("No file selected")
        self.filename.setFont(QFont('Arial', 9))
        self.filename.move(50, 200)

        button3 = QPushButton("Select data", self)
        button3.move(320, 200)
        button3.resize(80, 25)
        button3.clicked.connect(self.openFileNameDialog)

        self.textbox = QTextEdit(self)
        self.textbox.setGeometry(50, 50, 350, 60)
        self.textbox.setText("The model is ready to start training.\nPress Train.")
        self.textbox.setFont(QFont('Arial', 9))
        self.textbox.move(50, 240)

        self.button1 = QPushButton("Train", self)
        self.button1.move(50, 320)
        self.button1.resize(150, 60)
        self.button1.clicked.connect(self.train_model)
        self.button1.setEnabled(False)

        self.button2 = QPushButton("Predict", self)
        self.button2.move(250, 320)
        self.button2.resize(150, 60)
        self.button2.clicked.connect(self.test_model)
        self.button2.setEnabled(False)

        qbtn = QPushButton('Quit', self)
        qbtn.clicked.connect(QApplication.instance().quit)
        qbtn.resize(qbtn.sizeHint())
        qbtn.move(300, 420)

    def openFileNameDialog(self):
        options = QFileDialog.Options()
        options |= QFileDialog.DontUseNativeDialog
        fileName, _ = QFileDialog.getOpenFileName(self, "QFileDialog.getOpenFileName()", "",
                                                  "All Files (*);;Python Files (*.py)", options=options)
        global row_data
        self.filename.setText(fileName)
        if fileName:
            row_data = ntpath.basename(fileName)
            self.button1.setEnabled(True)

    def numberOfEpochsChanged(self):
        parameters.EPOCHS = self.spepochs.value()

    def numberOfUnitsChanged(self):
        parameters.UNITS =self.spunits.value()

    def numberOfLayersChanged(self):
        parameters.N_LAYERS = self.splayers.value()

    def changeName(self):
        before, after = self._before, self.text()
        parameters.model_name = self.Text()
        if before != after:
            self._before = after
            self.textModified.emit(before, after)

    def plot_graph(self, model, data):
        X_test = data["X_predict"]
        y_pred = model.predict(X_test)

        y_test = data["y_predict"]
        y_test = np.squeeze(data["column_scaler"]["Close"].inverse_transform(np.expand_dims(y_test, axis=0)))
        y_pred = np.squeeze(data["column_scaler"]["Close"].inverse_transform(y_pred))
        np.savetxt("1year30secTest.csv", y_pred, delimiter=",")

        tableau20 = [(31/255, 119/255, 180/255), (174/255, 199/255, 232/255), (255/255, 127/255, 14/255), (255/255, 187/255, 120/255)]

        plt.title('Prediction')
        plt.ylim([y_test[0] - 300, y_test[0] + 300])
        plt.plot(y_test[-5:], lw=2.5, color=tableau20[2])
        plt.plot(y_pred[-5:], lw=2.5, color=tableau20[3])
        plt.xlabel("Days")
        plt.ylabel("Price")
        plt.legend(["Actual Price", "Predicted Price"])

        self.textbox.setPlainText(self.textbox.toPlainText() + "Predicted results " + str(y_pred[-5:]) + "\n")
        plt.show()

    def plot_train_graph(self, model, data):
        x_train = data["X"]
        x_train = model.predict(x_train)


        y_train = data["y"]
        y_train = np.squeeze(data["column_scaler"]["Close"].inverse_transform(np.expand_dims(y_train, axis=0)))
        x_train = np.squeeze(data["column_scaler"]["Close"].inverse_transform(x_train))
        np.savetxt("1year30secTrain.csv", x_train, delimiter=",")

        tableau20 = [(31 / 255, 119 / 255, 180 / 255), (174 / 255, 199 / 255, 232 / 255),
                     (255 / 255, 127 / 255, 14 / 255), (255 / 255, 187 / 255, 120 / 255)]
        plt.plot(y_train, lw=2.5, color=tableau20[2])
        plt.plot(x_train, lw=2.5, color=tableau20[3])


        plt.title('Training phase')
        plt.xlabel("Days")
        plt.ylabel("Price")
        plt.legend(["Actual Price", "Predicted Price"])
        plt.show()

    def predict(self, model, data):
        # retrieve the last sequence from data
        last_sequence = data["last_sequence"]
        # retrieve the column scalers
        column_scaler = data["column_scaler"]
        # reshape the last sequence
        last_sequence = last_sequence.reshape((last_sequence.shape[1], last_sequence.shape[0]))
        # expand dimension
        last_sequence = np.expand_dims(last_sequence, axis=0)
        # get the prediction (scaled from 0 to 1)
        prediction = model.predict(last_sequence)
        # get the price (by inverting the scaling)
        predicted_price = column_scaler["Close"].inverse_transform(prediction)[0][0]

        return predicted_price


    def train_model(self):
        self.textbox.setPlainText('Training...')
        global row_data
        # create these folders if they does not exist
        cwd = os.getcwd()
        cwd = os.path.basename(cwd)
        if cwd == 'lstm':
            if not os.path.isdir("results"):
                os.mkdir("results")

            if not os.path.isdir("logs"):
                os.mkdir("logs")

            datadir = "./data"
            resultsdir = "results"
            logsdir = "logs"
        else:
            if not os.path.isdir("lstm/results"):
                os.mkdir("lstm/results")

            if not os.path.isdir("lstm/logs"):
                os.mkdir("lstm/logs")

            if not os.path.isdir("data"):
                os.mkdir("data")
            datadir = "data"
            resultsdir = "lstm/results"
            logsdir = "lstm/logs"

        # load the data
        data = load_data(parameters.ticker, parameters.N_STEPS, lookup_step=parameters.LOOKUP_STEP, test_size=parameters.TEST_SIZE, feature_columns=parameters.FEATURE_COLUMNS, row_data=row_data)

        # construct the model
        model = create_model(parameters.N_STEPS, loss=parameters.LOSS, units=parameters.UNITS, cell=parameters.CELL, n_layers=parameters.N_LAYERS,
                             dropout=parameters.DROPOUT, optimizer=parameters.OPTIMIZER)

        # some tensorflow callbacks
        checkpointer = ModelCheckpoint(os.path.join(resultsdir, parameters.model_name), save_weights_only=True, save_best_only=True,
                                       verbose=1)

        tensorboard = TensorBoard(log_dir=os.path.join(logsdir, parameters.model_name))

        print('# Fit model on training data')
        history = model.fit(data["X_train"], data["y_train"],
                            batch_size=parameters.BATCH_SIZE,
                            epochs=parameters.EPOCHS,
                            validation_data=(data["X_test"], data["y_test"]),
                            callbacks=[checkpointer, tensorboard],
                            verbose=1)

        model.save(os.path.join(resultsdir, parameters.model_name) + ".h5")
        if not cwd == 'lstm':
            self.plot_train_graph(model, data)


        self.textbox.setPlainText('The model finished training. Proceed with testing.')
        self.button2.setEnabled(True)


    def test_model(self):
        global row_data
        cwd = os.getcwd()
        cwd = os.path.basename(cwd)
        if cwd == 'lstm':
            resultsdir = "results"
            logsdir = "logs"
        else:
            resultsdir = "lstm/results"

        self.textbox.setText('Testing...')
        # load the data
        data = load_data(ticker, parameters.N_STEPS, lookup_step=parameters.LOOKUP_STEP, test_size=parameters.TEST_SIZE,
                         feature_columns=parameters.FEATURE_COLUMNS, shuffle=False, row_data =row_data)

        #   construct the model
        model = create_model(N_STEPS, loss=parameters.LOSS, units=parameters.UNITS, cell=parameters.CELL, n_layers=parameters.N_LAYERS,
                             dropout=parameters.DROPOUT, optimizer=parameters.OPTIMIZER)

        model_path = os.path.join(resultsdir, parameters.model_name) + ".h5"
        model.load_weights(model_path)

        # evaluate the model
        results = model.evaluate(data["X_test"], data["y_test"])

        self.textbox.setPlainText('test loss, test acc:' + str(results) + '\n')

        if not cwd == 'lstm':
            print("Results: " + str(results))
            print('test loss, test acc:', results)
            self.plot_graph(model, data)



def start():
    app = QApplication(sys.argv)
    win = Window()
    win.show()
    sys.exit(app.exec_())

if __name__ == '__main__':
    start()