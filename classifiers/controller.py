import numpy as np
from keras.callbacks import ModelCheckpoint
from sklearn.preprocessing import StandardScaler
import keras
from classifiers.baselines import Classifier
from classifiers.data_set import produce_data_set

BATCH_SIZE = 128
HIDDEN_DIM = 128
NB_EPOCH = 100
PATH = "../max.csv"

seed = 155
np.random.seed(seed)

X_train, X_test, Y_train, Y_test = produce_data_set(PATH)

scaler = StandardScaler()

X_train_fitted = scaler.fit_transform(X_train)
X_test_fitted = scaler.fit_transform(X_test)

classifier = Classifier(HIDDEN_DIM, X_train.shape[1], HIDDEN_DIM, X_train.shape[1])

early_stop_criteria = keras.callbacks.EarlyStopping(monitor='val_loss', min_delta=0,
                                                    patience=20, verbose=0, mode='auto')
model_callbacks_little = [early_stop_criteria]
model_callbacks_large = [early_stop_criteria]
file_little_path = "models/nn_little_weights_%dneurons-{epoch:02d}.hdf5" % HIDDEN_DIM
file_large_path = "models/nn_large_weights_%dneurons-{epoch:02d}.hdf5" % HIDDEN_DIM

checkpoint_little = ModelCheckpoint(file_little_path, monitor='val_acc', verbose=0, save_weights_only=True,
                                    save_best_only=False, mode='max')
checkpoint_large = ModelCheckpoint(file_large_path, monitor='val_acc', verbose=0, save_weights_only=True,
                                   save_best_only=False, mode='max')

model_callbacks_little.append(checkpoint_little)
model_callbacks_large.append(checkpoint_large)

# decision_tree = classifier.decision_tree.fit(X_train, Y_train)
little_nn = classifier.little_nn.fit(X_train_fitted, Y_train, epochs=NB_EPOCH, verbose=1, batch_size=BATCH_SIZE,
                                     callbacks=model_callbacks_little, validation_split=0.2)
large_nn = classifier.large_nn.fit(X_train_fitted, Y_train, epochs=NB_EPOCH, verbose=1, batch_size=BATCH_SIZE,
                                   callbacks=model_callbacks_large, validation_split=0.2)
