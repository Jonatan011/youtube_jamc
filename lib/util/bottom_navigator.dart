import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BotomMenuYoutube extends StatelessWidget {
  const BotomMenuYoutube({super.key});
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      unselectedItemColor: Colors.black,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.house),
          label: "Principal",
        ),
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.compass),
          label: "Explorar",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            FontAwesomeIcons.circlePlus,
          ),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.subscriptions_outlined),
          label: "Suscripciones",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_add_outlined),
          label: "Biblioteca",
        ),
      ],
      currentIndex: 0, //_selectIndex,
      selectedItemColor: Colors.black,
      onTap: (index) {
        /*setState(() {
          _selectIndex = index;

          switch (_selectIndex) {
            case 0:
              //Navigator.pushNamed(context, PrincipalPage.id);
              Navigator.pushReplacementNamed(context, PrincipalPage.id);
              break;
            case 1:
              //Navigator.pushNamed(context, ExplorePage.id);
              Navigator.pushReplacementNamed(context, ExplorePage.id);
              break;
            case 2:
              MaterialPage(
                  child: Container(
                color: Colors.red,
                height: 200.0,
                width: 200.0,
              ));
              break;
            default:
          }
        });*/
      },
    );
  }
}
