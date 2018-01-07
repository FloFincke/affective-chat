import keras
import matplotlib.pyplot as plt
import numpy as np
import os

from keras.callbacks import ModelCheckpoint
from sklearn.metrics import accuracy_score
from sklearn.preprocessing import StandardScaler

from classifiers.baselines import Classifier
from classifiers.data_set import produce_data_set

BATCH_SIZE = 128
HIDDEN_DIM = 175

# NB_EPOCH = 10000
NB_EPOCH = 2
PATH = "../vince.csv"

seed = 155
np.random.seed(seed)

X_train, X_test, Y_train, Y_test = produce_data_set(PATH)

print('X_train len: ' + str(len(X_train)))
print('Y_train len: ' + str(len(Y_train)))
print('X_test len: ' + str(len(X_test)))
print('Y_test len: ' + str(len(Y_test)))
print(X_train[0])
print(Y_train[0])

scaler = StandardScaler()

X_train_fitted = scaler.fit_transform(X_train)
X_test_fitted = scaler.fit_transform(X_test)

classifier = Classifier(HIDDEN_DIM, X_train.shape[1], HIDDEN_DIM, X_train.shape[1])
# classifier = Classifier(X_train.shape[0], X_train.shape[1], X_train.shape[0], X_train.shape[1])

early_stop_criteria = keras.callbacks.EarlyStopping(monitor='val_loss', min_delta=0,
                                                    patience=80, verbose=0, mode='auto')
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

Y_train_dt = Y_train.astype('int')
Y_test_dt = Y_test.astype('int')

decision_tree = classifier.decision_tree.fit(X_train, Y_train_dt)
little_nn = classifier.little_nn.fit(X_train_fitted, Y_train, epochs=NB_EPOCH, verbose=2, batch_size=X_train.shape[0],
                                     callbacks=model_callbacks_little, validation_split=0.2, initial_epoch=0).history
large_nn = classifier.large_nn.fit(X_train_fitted, Y_train, epochs=NB_EPOCH, verbose=2, batch_size=X_train.shape[0],
                                   callbacks=model_callbacks_large, validation_split=0.2, initial_epoch=0).history


predictions_tree = decision_tree.predict(X_test)

print('Accuracy Tree: ' + str(accuracy_score(Y_test_dt, predictions_tree)))

test_classifier = Classifier(HIDDEN_DIM, X_train.shape[1], HIDDEN_DIM, X_train.shape[1])

test_over_time_little = []
test_over_time_large = []

for i in range(len(little_nn['loss'])):
    test_classifier.little_nn.load_weights("models/nn_little_weights_%dneurons-%02d.hdf5" % (HIDDEN_DIM, i))
    scores = test_classifier.little_nn.evaluate(X_test_fitted, Y_test, verbose=0)
    test_over_time_little.append(scores)
    # remove
    os.remove("models/nn_little_weights_%dneurons-%02d.hdf5" % (HIDDEN_DIM, i))

for i in range(len(large_nn['loss'])):
    test_classifier.large_nn.load_weights("models/nn_large_weights_%dneurons-%02d.hdf5" % (HIDDEN_DIM, i))
    scores = test_classifier.large_nn.evaluate(X_test_fitted, Y_test, verbose=0)
    test_over_time_large.append(scores)
    # remove
    os.remove("models/nn_large_weights_%dneurons-%02d.hdf5" % (HIDDEN_DIM, i))

test_over_time_little = np.array(test_over_time_little)
test_over_time_large = np.array(test_over_time_large)
little_nn['test_loss'] = [row[0] for row in test_over_time_little]
little_nn['test_acc'] = [row[1] for row in test_over_time_little]
large_nn['test_loss'] = [row[0] for row in test_over_time_large]
large_nn['test_acc'] = [row[1] for row in test_over_time_large]

print(little_nn)
print(large_nn)

fig, (ax1, ax2) = plt.subplots(2, 1)
ax1.plot(range(len(little_nn['val_loss'])), little_nn['val_loss'], linestyle='-', color='mediumpurple',
         label='Validation (Standardised)', lw=2)
ax1.plot(range(len(little_nn['test_loss'])), little_nn['test_loss'], linestyle='-', color='lightgreen',
         label='Test (Standardised)', lw=2)
ax2.plot(range(len(little_nn['val_acc'])), little_nn['val_acc'], linestyle='-', color='mediumpurple',
         label='Validation (Standardised)', lw=2)
ax2.plot(range(len(little_nn['test_acc'])), little_nn['test_acc'], linestyle='-', color='lightgreen',
         label='Test (Standardised)', lw=2)
leg = ax1.legend(bbox_to_anchor=(0.5, 0.95), loc=2, borderaxespad=0., fontsize=13)
ax1.set_xticklabels('')
ax2.set_xlabel('# Epochs', fontsize=14)
ax1.set_ylabel('Loss Little', fontsize=14)
ax2.set_ylabel('Accuracy Little', fontsize=14)
plt.tight_layout()
plt.show()

fig, (ax1, ax2) = plt.subplots(2, 1)
ax1.plot(range(len(large_nn['val_loss'])), large_nn['val_loss'], linestyle='-', color='mediumpurple',
         label='Validation (Standardised)', lw=2)
ax1.plot(range(len(large_nn['test_loss'])), large_nn['test_loss'], linestyle='-', color='lightgreen',
         label='Test (Standardised)', lw=2)
ax2.plot(range(len(large_nn['val_acc'])), large_nn['val_acc'], linestyle='-', color='mediumpurple',
         label='Validation (Standardised)', lw=2)
ax2.plot(range(len(large_nn['test_acc'])), large_nn['test_acc'], linestyle='-', color='lightgreen',
         label='Test (Standardised)', lw=2)
leg = ax1.legend(bbox_to_anchor=(0.5, 0.95), loc=2, borderaxespad=0., fontsize=13)
ax1.set_xticklabels('')
ax2.set_xlabel('# Epochs', fontsize=14)
ax1.set_ylabel('Loss Large', fontsize=14)
ax2.set_ylabel('Accuracy Large', fontsize=14)
plt.tight_layout()
plt.show()
