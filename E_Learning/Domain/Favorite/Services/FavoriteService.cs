using E_Learning.Data;
using E_Learning.Domain.Favorite.Dtos;
using E_Learning.Domain.Favorite.Interface;
using E_Learning.Entity;
using Microsoft.EntityFrameworkCore;

namespace E_Learning.Domain.Favorite.Services
{
    public class FavoriteService : IFavoriteService
    {
        private readonly AppDbContext _context;

        public FavoriteService(AppDbContext context)
        {
            _context = context;
        }

        public async Task AddFavoriteAsync(Guid userId, Guid wordId)
        {
            var wordExists = await _context.VocabularyWords
                .AnyAsync(x => x.WordId == wordId);

            if (!wordExists)
                throw new Exception("Word not found.");

            var exists = await _context.UserFavoriteWords
                .AnyAsync(x => x.UserId == userId && x.WordId == wordId);

            if (exists)
                return;

            var favorite = new UserFavoriteWord
            {
                UserId = userId,
                WordId = wordId
            };

            _context.UserFavoriteWords.Add(favorite);
            await _context.SaveChangesAsync();
        }

        public async Task RemoveFavoriteAsync(Guid userId, Guid wordId)
        {
            var favorite = await _context.UserFavoriteWords
                .FirstOrDefaultAsync(x => x.UserId == userId && x.WordId == wordId);

            if (favorite == null)
                return;

            _context.UserFavoriteWords.Remove(favorite);
            await _context.SaveChangesAsync();
        }

        public async Task<List<FavoriteWordDto>> GetFavoritesAsync(Guid userId)
        {
            var result = await _context.UserFavoriteWords
                .Where(f => f.UserId == userId)
                .Join(
                    _context.VocabularyWords,
                    f => f.WordId,
                    w => w.WordId,
                    (f, w) => new { f, w }
                )
                .GroupJoin(
                    _context.VocabularyTopics,
                    fw => fw.w.TopicId,
                    t => t.TopicId,
                    (fw, topics) => new { fw.f, fw.w, topics }
                )
                .SelectMany(
                    x => x.topics.DefaultIfEmpty(),
                    (x, t) => new FavoriteWordDto
                    {
                        WordId = x.w.WordId,
                        WordText = x.w.WordText,
                        Meaning = x.w.Meaning,
                        PartOfSpeech = x.w.PartOfSpeech,
                        Phonetic = x.w.Phonetic,
                        ImageUrl = x.w.ImageUrl,
                        TopicId = x.w.TopicId,
                        TopicName = t != null ? t.TopicName : null,
                        IsFavorite = true
                    }
                )
                .OrderBy(x => x.WordText)
                .ToListAsync();

            return result;
        }
    }
}