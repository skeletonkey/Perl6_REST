use v6;

use JSON::Fast;

class Jundy::View {
    method encode(@data) {
        return to-json @data;
    }

    method decode($string) {
        return from-json($string);
    }
}