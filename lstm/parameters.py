import os
import time
from tensorflow.keras.layers import LSTM

# Window size or the sequence length
N_STEPS = 5
# Lookup step, 1 is the next day
LOOKUP_STEP = 1

# test ratio size, 0.2 is 20%
TEST_SIZE = 0.1
# features to use
FEATURE_COLUMNS = ["Open", 'Close', "OpenMax", "OpenMin", "Day"]
# date now
date_now = time.strftime("%Y-%m-%d")

### model parameters
TRAIN_RAW = True
N_LAYERS = 4
# LSTM cell
CELL = LSTM
# 256 LSTM neurons
UNITS = 12
# 40% dropout
DROPOUT = 0.3

### training parameters

# mean squared error loss
LOSS = "mse"
OPTIMIZER = "rmsprop"
BATCH_SIZE = 16
EPOCHS = 300

# Apple stock market
ticker = "WIG20"
ticker_data_filename = os.path.join("data", f"WIG20_d.csv")
# model name to save
model_name = f"{date_now}_{ticker}-{LOSS}-{CELL.__name__}-seq-{N_STEPS}-step-{LOOKUP_STEP}-layers-{N_LAYERS}-units-{UNITS}"

# Row data name
global row_data
