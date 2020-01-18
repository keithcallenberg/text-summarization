import tensorflow as tf
import pickle
from model import Model
from utils import build_dict, build_dataset, batch_iter, word_tokenize, clean_str
import logging


class Summarize(object):
    """
    Model template. You can load your model parameters in __init__ from a location accessible at runtime
    """

    def __init__(self):
        """
        Add any initialization parameters. These will be passed at runtime from the graph definition parameters defined in your seldondeployment kubernetes resource manifest.
        """
        with open("args.pickle", "rb") as f:
            self.args = pickle.load(f)

        self.word_dict, self.reversed_dict, self.article_max_len, self.summary_max_len = build_dict("valid", False)

    def predict(self, X, feature_names):
        """
        Return a prediction.

        Parameters
        ----------
        X : array-like
        """
        logging.warning(X)

        with tf.Session() as sess:
            logging.info("Loading saved model...")
            model = Model(self.reversed_dict, self.article_max_len, self.summary_max_len, self.args, forward_only=True)
            saver = tf.train.Saver(tf.global_variables())
            ckpt = tf.train.get_checkpoint_state("./saved_model/")
            saver.restore(sess, ckpt.model_checkpoint_path)

            # prep model input
            valid_x = self.prep_input(X)

            batches = batch_iter(valid_x, [0] * len(valid_x), self.args.batch_size, 1)

            for batch_x, _ in batches:
                batch_x_len = [len([y for y in x if y != 0]) for x in batch_x]

                valid_feed_dict = {
                    model.batch_size: len(batch_x),
                    model.X: batch_x,
                    model.X_len: batch_x_len,
                }

                prediction = sess.run(model.prediction, feed_dict=valid_feed_dict)
                prediction_output = [[self.reversed_dict[y] for y in x] for x in prediction[:, 0, :]]

        return prediction_output

    def prep_input(self, input):
        # clean input
        article_list = [clean_str(x.strip()) for x in input]

        # tokenize
        x = [word_tokenize(d) for d in article_list]

        # replace with dictionary or unk
        x = [[self.word_dict.get(w, self.word_dict["<unk>"]) for w in d] for d in x]

        # trim as necessary
        x = [d[:self.article_max_len] for d in x]
        x = [d + (self.article_max_len - len(d)) * [self.word_dict["<padding>"]] for d in x]

        return x

    def health_status(self):
        response = self.predict(["us auto sales will likely be weaker in #### , a senior executive at ford motor company said wednesday .",
                                 "the los angeles dodgers acquired south korean right-hander jae seo from the new york mets on wednesday in a four-player swap ."])
        assert len(response) == 2, "health check returning bad predictions"
        return response
