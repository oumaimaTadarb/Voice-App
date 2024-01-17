import 'package:flutter_voiceapp/Drawer.dart';
import 'package:flutter_voiceapp/box.dart';
import 'package:flutter_voiceapp/openai_service.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_voiceapp/pallete.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedLanguage = "English";
  final speechToText =
      SpeechToText(); //Instance de la classe SpeechToText utilisée pour la reconnaissance vocale.
  final flutterTts =
      FlutterTts(); //Instance de la classe FlutterTts utilisée pour la synthèse vocale.
  String lastWords =
      ''; //Chaîne de caractères pour stocker les derniers mots reconnus par la reconnaissance vocale.
  final OpenAIService openAIService =
      OpenAIService(); // utilisée pour interagir avec le service OpenAI.
  String? generatedContent; //texte généré
  String? generatedImageUrl; //image généré
  int start = 200;
  int delay = 200;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

//initialiser synthèse vocale
  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    //contient info de rec vocale
    setState(() {
      //etat de widget m à j ,with last word
      lastWords = result.recognizedWords;
    });
  } //lorsque le résultat est disponible

  Future<void> systemSpeak(String content) async {
    //déclencher la synthèse vocale
    await flutterTts.speak(content);
  }

//when le widget associé à cet état est retiré de l'arborescence des widgets.fuite de mem
  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawerr(
        language: selectedLanguage,
        onLanguageChanged: (newLanguage) {
          setState(() {
            selectedLanguage = newLanguage;
          });
        },
      ),
      appBar: AppBar(
        title: BounceInDown(
          //effet de transition
          child: const Text('Voice APP'),
        ),
        leading: const Icon(Icons.menu), //icon à gauche
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        //défiler le content si dépasse l'ecran
        child: Column(
          children: [
            // virtual assistant picture
            ZoomIn(
              //est utilisé  comme un effet de transition pour agrandir l enfant
              child: Stack(
                // superposer plusieurs widgets.
                children: [
                  Center(
                    //Un widget Container est centré dans le Stack
                    child: Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.only(top: 4), //marging
                      decoration: const BoxDecoration(
                        //style visuel
                        color: Pallete.assistantCircleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Container(
                    height: 123,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle, //forme du conteneur cercle
                      image: DecorationImage(
                        //définir image , font du cont
                        image: AssetImage(
                          'assets/images/img.jpg',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // chat bubble
            FadeInRight(
              //appliquer une animation de fondu à droite à son enfan
              child: Visibility(
                //conditionner l'affichage de  enfant en fonction de generatedImageUrl
                visible: generatedImageUrl == null,
                //enfantvisible
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    //remplissage interne padding
                    horizontal: 20,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(
                    top: 30,
                  ),
                  decoration: BoxDecoration(
                    //style visuel
                    border: Border.all(
                      color: Pallete.borderColor,
                    ),
                    borderRadius: BorderRadius.circular(20).copyWith(
                      topLeft: Radius.zero,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      generatedContent == null //affiche un texte par defaut
                          ? 'Good Morning, what task can I do for you?'
                          : generatedContent!,
                      style: TextStyle(
                        fontFamily: 'Cera Pro',
                        color: Pallete.mainFontColor,
                        fontSize: generatedContent == null ? 25 : 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (generatedImageUrl != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  //appliquer un masque arrondi à son enfant.
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(generatedImageUrl!),
                ),
              ),
            SlideInLeft(
              //appliquer une animation de glissement depuis la gauche à son enfant
              child: Visibility(
                //conditionner l'affichage de son enfant en fonction des valeurs de generatedContent et generatedImageUrl
                visible: generatedContent == null && generatedImageUrl == null,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 10, left: 22),
                  child: const Text(
                    'Here are a few features',
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Pallete.mainFontColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // features list
            Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
              child: Column(
                children: [
                  SlideInLeft(
                    //appliquer une animation de glissement depuis la gauche à son enf
                    delay: Duration(milliseconds: start),
                    child: const FeatureBox(
                      //enfant
                      color: Pallete.firstSuggestionBoxColor,
                      headerText: 'ChatGPT',
                      descriptionText:
                          'A smarter way to stay organized and informed with ChatGPT',
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + delay),
                    child: const FeatureBox(
                      color: Pallete.secondSuggestionBoxColor,
                      headerText: 'Dall-E',
                      descriptionText:
                          'Get inspired and stay creative with your personal assistant powered by Dall-E',
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: ZoomIn(
        //appliquer une animation de zoom à son enfant
        delay: Duration(milliseconds: start + 3 * delay),
        child: FloatingActionButton(
          backgroundColor: Pallete.firstSuggestionBoxColor,
          onPressed: () async {
            if (await speechToText.hasPermission &&
                speechToText.isNotListening) {
              await startListening();
            } else if (speechToText.isListening) {
              final speech = await openAIService.isArtPromptAPI(lastWords);
              if (speech.contains('https')) {
                // Si la réponse de l'API OpenAI contient une URL (pour une image), met à jour les variables
                generatedImageUrl = speech;
                generatedContent = null;
                setState(() {});
              } else {
                generatedImageUrl = null;
                generatedContent = speech;
                setState(() {});
                await systemSpeak(speech);
              }
              print(lastWords);
              await stopListening();
            } else {
              initSpeechToText();
            }
          },
          child: Icon(
            speechToText.isListening ? Icons.stop : Icons.mic,
          ),
        ),
      ),
    );
  }
}
