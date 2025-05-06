from flask import Flask, request, jsonify
from transformers import pipeline
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Enable CORS to allow requests from your Flutter app

# Load the RoBERTa sentiment analysis model
print("Loading RoBERTa model...")
classifier = pipeline('sentiment-analysis', model='cardiffnlp/twitter-roberta-base-sentiment')
print("RoBERTa model loaded successfully.")

def get_sentiment_score(text):
    result = classifier(text)[0]
    label = result['label']
    score = result['score']

    # Convert model output to a meaningful score for your app
    if label == 'LABEL_0':  # Negative
        return round(-10 * score, 2)
    elif label == 'LABEL_1':  # Neutral
        return 0
    elif label == 'LABEL_2':  # Positive
        return round(10 * score, 2)

@app.route('/analyze', methods=['POST'])
def analyze():
    try:
        data = request.json
        sentences = data.get('sentences', [])
        
        if not sentences:
            return jsonify({"error": "No sentences provided"}), 400

        scores = {sentence: get_sentiment_score(sentence) for sentence in sentences}
        return jsonify(scores)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
