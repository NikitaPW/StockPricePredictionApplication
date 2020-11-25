import os
import parameters
import sys
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *
from PyQt5.QtCore import *
from stock_prediction import create_model, load_data
from tensorflow.keras.layers import LSTM
from tensorflow.keras.callbacks import ModelCheckpoint, TensorBoard
import pandas as pd
import matplotlib.pyplot as plt
from parameters import *
from sklearn.metrics import accuracy_score
import numpy as np



class Window(QWidget):
    def __init__(self):
        super().__init__()
        self.title = "LSTM for Stock Price Prediction"
        self.left = 300
        self.top = 300
        self.width = 500
        self.height = 600
        self.initUI()

    def initUI(self):

        label1 = QLabel('Arial font', self)
        label1.setGeometry(15, 15, 500, 32)
        label1.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        label1.setText("LSTM for Stock Price Prediction")
        label1.move(65, 15)
        label1.setAlignment(Qt.AlignCenter)
        label1.setFont(QFont('Arial', 16))

        button1 = QPushButton("Train", self)
        button1.move(125, 80)
        button1.resize(150, 70)
        button1.clicked.connect(self.button1_clicked)

        button2 = QPushButton("Test", self)
        button2.move(350, 80)
        button2.resize(150, 70)
        button2.clicked.connect(self.button2_clicked)

        qbtn = QPushButton('Quit', self)
        qbtn.clicked.connect(QApplication.instance().quit)
        qbtn.resize(qbtn.sizeHint())
        qbtn.move(470, 240)

        self.textbox = QTextEdit(self)
        self.textbox.setGeometry(50, 50, 300, 40)
        self.textbox.setText("The model is ready to start training.\nPress Train.")
        #label3.setText("Here the flow of the program will be displayed. \nTraining... Trained. Testing... Tested. \nThe prediction is: ")
        self.textbox.setFont(QFont('Arial', 7))
        self.textbox.move(150, 170)


    def plot_graph(self, model, data):
        X_test = data["X_test"]
        y_pred = model.predict(X_test)
        y_test = data["y_test"]
        y_test = np.squeeze(data["column_scaler"]["Close"].inverse_transform(np.expand_dims(y_test, axis=0)))
        y_pred = np.squeeze(data["column_scaler"]["Close"].inverse_transform(y_pred))



        tableau20 = [(31/255, 119/255, 180/255), (174/255, 199/255, 232/255), (255/255, 127/255, 14/255), (255/255, 187/255, 120/255)]

        plt.title('Prediction')
        plt.plot(y_test[-5:], lw=2.5, color=tableau20[2])
        plt.plot(y_pred[-5:], lw=2.5, color=tableau20[3])
        plt.xlabel("Days")
        plt.ylabel("Price")
        plt.legend(["Actual Price", "Predicted Price"])
        self.textbox.setPlainText(self.textbox.toPlainText() + "Predicted results " + str(y_pred[-5:]) + "\n")
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


    def button1_clicked(self):
        self.textbox.setPlainText('Training...')
        # create these folders if they does not exist
        if not os.path.isdir("results"):
            os.mkdir("results")

        if not os.path.isdir("logs"):
            os.mkdir("logs")

        if not os.path.isdir("data"):
            os.mkdir("data")

        # load the data
        data = load_data(ticker, N_STEPS, lookup_step=LOOKUP_STEP, test_size=TEST_SIZE, feature_columns=FEATURE_COLUMNS)

        # construct the model
        model = create_model(N_STEPS, loss=LOSS, units=UNITS, cell=CELL, n_layers=N_LAYERS,
                             dropout=DROPOUT, optimizer=OPTIMIZER)

        # some tensorflow callbacks
        checkpointer = ModelCheckpoint(os.path.join("results", model_name), save_weights_only=True, save_best_only=True,
                                       verbose=1)
        tensorboard = TensorBoard(log_dir=os.path.join("logs", model_name))

        print('# Fit model on training data')
        history = model.fit(data["X_train"], data["y_train"],
                            batch_size=BATCH_SIZE,
                            epochs=EPOCHS,
                            validation_data=(data["X_test"], data["y_test"]),
                            callbacks=[checkpointer, tensorboard],
                            verbose=1)

        model.save(os.path.join("results", model_name) + ".h5")
        self.textbox.setPlainText('The model finished training. Proceed with testing.')


    def button2_clicked(self):
        self.textbox.setText('Testing...')
        # load the data
        data = load_data(ticker, N_STEPS, lookup_step=LOOKUP_STEP, test_size=TEST_SIZE,
                         feature_columns=FEATURE_COLUMNS, shuffle=False)

        #   construct the model
        model = create_model(N_STEPS, loss=LOSS, units=UNITS, cell=CELL, n_layers=N_LAYERS,
                             dropout=DROPOUT, optimizer=OPTIMIZER)

        model_path = os.path.join("results", model_name) + ".h5"
        model.load_weights(model_path)

        # evaluate the model
        results = model.evaluate(data["X_test"], data["y_test"])
        self.textbox.setPlainText('test loss, test acc:' + str(results) + '\n')
        print('test loss, test acc:', results)

        self.plot_graph(model, data)


def start():
    app = QApplication(sys.argv)
    win = Window()
    win.show()
    sys.exit(app.exec_())

if __name__ == '__main__':
    start()