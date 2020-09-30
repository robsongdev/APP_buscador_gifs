import 'package:buscador_gifs/ui/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _offsset = 0; // quantidade de paginas

  Future<Map> _getGifs() async {
    http.Response response;

    if (_search == null || _search.isEmpty) {
      //se não houver pesquisa, mostrar os melhores gifs
      response = await http.get(
          "https://api.giphy.com/v1/gifs/trending?api_key=Yt3U7PEBNHVyj1KtLBlLGZVjryXV8No5&limit=20&rating=g");
    } else {
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=Yt3U7PEBNHVyj1KtLBlLGZVjryXV8No5&q=$_search&limit=19&offset=$_offsset&rating=g&lang=en");
    }

    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"), //title como imagem
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Pesquise aqui",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder()),
              style: TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                //chamando ao dar "ok" no teclado
                setState(() {
                  _search = text;
                  _offsset = 0; //reseta as "paginas"
                });
              },
            ),
          ),
          Expanded(
              child: FutureBuilder(
                  future: _getGifs(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:

                        //CIRCULO ANIMADO DE CARREGAMENTO
                        return Container(
                          width: 200,
                          height: 200,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            //cor sempre branca,sem alterações
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 5, //largura da animação
                          ),
                        );

                      default:
                        if (snapshot.hasError)
                          return Container();
                        else
                          return _createGifTable(context, snapshot);
                    }
                  }))
        ],
      ),
    );
  }

// CONTAGEM DE GRID DE ACORDO COM O _search
  int _getCount(List data) {
    if (_search == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  //CRIANDO TABELA DE GIFS
  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: EdgeInsets.all(10),
        //como os itens vão se organizar
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //quantos itens na horizontal
            crossAxisCount: 2,

            //espaçamento entre os itens horizontal
            crossAxisSpacing: 10,

            //espaçamento vertical
            mainAxisSpacing: 10),

        //quantidade de itens
        itemCount: _getCount(snapshot.data["data"]),

        //como cada item vai se comportar
        itemBuilder: (context, index) {
          if (_search == null || index < snapshot.data["data"].length)
            //para poder clicar no GIF
            return GestureDetector(
              //pegando Gif
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: snapshot.data["data"][index]["images"]["fixed_height_downsampled"]["url"],
                height: 300,
                fit: BoxFit.cover,
              ),
              onTap: () {
                //MUDANDO DE PAGINA AO CLICAR NO GIF
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            GifPage(snapshot.data["data"][index])));
              },
              onLongPress: (){
                Share.share(snapshot.data["data"][index]["images"]["fixed_height_downsampled"]["url"]);
              },
            );
          else
            //BOTÃO CARREGAR MAIS
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 70,
                    ),
                    Text(
                      "Carregar Mais...",
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    )
                  ],
                ),
                onTap: () {
                  //ao aperta o widget ser ao mentado o numero de Gif
                  setState(() {
                    _offsset += 19;
                  });
                },
              ),
            );
        });
  }
}
