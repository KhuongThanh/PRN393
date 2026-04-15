using E_Learning.Domain.Vocabulary.Interface;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace E_Learning.Domain.Vocabulary.Controllers
{
    [ApiController]
    [Route("api/vocabulary-topics")]
    public class VocabularyTopicsController : ControllerBase
    {
        private readonly IVocabularyTopicService _topicService;

        public VocabularyTopicsController(IVocabularyTopicService topicService)
        {
            _topicService = topicService;
        }

        [HttpGet]
        public async Task<IActionResult> GetTopics()
        {
            var result = await _topicService.GetTopicsAsync();
            return Ok(result);
        }
    }
    }