export const IMG = {
  poster: path =>
    path ? `https://image.tmdb.org/t/p/w342${path}` : '/poster-fallback.png',
  avatar: path =>
    path ? `https://image.tmdb.org/t/p/w185${path}` : '/avatar-fallback.png',
};
