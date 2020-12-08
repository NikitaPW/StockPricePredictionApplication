import os

from parameters import *
from stock_prediction import *
from start import *
import numpy as np

#script containing unit tests for the functions used in applicaition
def data_creation_test():
    print("--------------TEST_1_load_data--------------")
    data_loaded = load_data(parameters.ticker, parameters.N_STEPS, lookup_step=parameters.LOOKUP_STEP, test_size=parameters.TEST_SIZE, feature_columns=parameters.FEATURE_COLUMNS)
    if not {"Open", "Close", "OpenMax", "OpenMin", "Day"}.issubset(data_loaded["df"].columns):
        print("Test was not passed!")
        return
    print(".")

    if not os.path.exists('./data'):
        print("Test was not passed!")
        return
    print(".")

    df = data_loaded["df"]
    if not np.logical_and(df["Open"].any() >= 0, df["Open"].any() <= 1):
        print("Test was not passed!")
        return
    print(".")

    if not "X_predict" and "y_predict" in dict.keys():
        print("Test was not passed!")
        return
    print(".")

    if not "X_train" and "X_test" in dict.keys():
        print("Test was not passed!")
        return

    print("--------------TEST_1 PASSED--------------")

def create_model_test():
    print("--------------TEST_2_create_model--------------")

    model = create_model(N_STEPS, loss=LOSS, units=UNITS, cell=CELL, n_layers=N_LAYERS,
                             dropout=DROPOUT, optimizer=OPTIMIZER)
    print(".")
    model.save(os.path.join("results", model_name) + ".h5")
    if not (os.path.isfile("./results/" + model_name)):
        print("Test was not passed!")
        return
    print(".")
    print("--------------TEST_2 PASSED--------------")

def train_model_test():
    print("--------------TEST_3_train_model--------------")

    if not os.path.exists("logs") or not os.path.exists("results"):
        print("Test was not passed!")
        return

    print(".")
    app = QApplication(sys.argv)
    win = Window()
    win.train_model()
    print(".")
    model_name = f"{date_now}_{ticker}-{LOSS}-{CELL.__name__}-seq-{N_STEPS}-step-{LOOKUP_STEP}-layers-{N_LAYERS}-units-{UNITS}" + ".h5"
    if not (os.path.isfile("./results/"+model_name)):
        print("Test was not passed!")
        return

    print("--------------TEST_3 PASSED--------------")

def test_model_test():
    print("--------------TEST_4_test_model--------------")
    app = QApplication(sys.argv)
    win = Window()
    win.test_model()
    print(".")
    if win.textbox.toPlainText() == "":
        print("Test was not passed!")
        return

    print("--------------TEST_4_PASSED--------------")


def test_epochs_change():
    print("--------------TEST_5_epochs_changed--------------")
    app = QApplication(sys.argv)
    win = Window()
    win.spepochs.setValue(300)
    if EPOCHS != 300:
        print("The test wasn't passed!")
        return

    print("--------------TEST_5_PASSED--------------")


def test_units_changed():
    print("--------------TEST_6_units_changed--------------")
    app = QApplication(sys.argv)
    win = Window()
    win.spunits.setValue(12)
    if UNITS != 12:
        print("The test wasn't passed!")
        return

    print("--------------TEST_6_PASSED--------------")


def test_layers_changed():
    print("--------------TEST_7_layers_changed--------------")
    app = QApplication(sys.argv)
    win = Window()
    win.splayers.setValue(4)
    if N_LAYERS != 4:
        print("The test wasn't passed!")
        return

    print("--------------TEST_7_PASSED--------------")


def test_gui_popup():
    print("--------------TEST_8_gui_popup--------------")
    app = QApplication(sys.argv)
    win = Window()
    win.textbox.setText("Please, close the window to proceed with testing")
    win.show()
    sys.exit(app.exec_())
    print("--------------TEST_8_PASSED--------------")

if __name__ == '__main__':
    data_creation_test()
    create_model_test()
    train_model_test()
    test_model_test()
    test_epochs_change()
    test_units_changed()
    test_layers_changed()
    test_gui_popup()